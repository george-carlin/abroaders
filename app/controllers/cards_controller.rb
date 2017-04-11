class CardsController < AuthenticatedUserController
  onboard :owner_cards, :companion_cards, with: [:survey, :save_survey]

  def index
    # Unfortunately I can't figure out a better way of avoiding all the N+1 issues
    # without reloading the current account, since you can't call `includes`
    # after the account has already been loaded.
    @account = Account.includes(
      people: [:account, { card_accounts: { product: :bank } },
               unresolved_card_recommendations: [:product, { product: :bank, offer: { product: :currency } }],],
    ).find(current_account.id)
    @any_recommendations = @account.unresolved_card_recommendations.any?
    if @any_recommendations
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    # admins can't edit notes, so our crude way of allowing it for now
    # is to let admins submit a new updated note, and we only ever show
    # the most recent note to the user:
    @newest_rec_note = @account.recommendation_notes.order(created_at: :desc).first

    @account.card_recommendations.unseen.update_all(seen_at: Time.zone.now)
  end

  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    @survey = CardProduct::Survey.new(person: @person)
  end

  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardProduct::Survey.new(survey_params.merge(person: @person)).save!
    # track_intercom_event("obs_cards_#{@person.type[0..2]}")
    redirect_to onboarding_survey_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def survey_params
    if params.key?(:cards_survey)
      params.require(:cards_survey).permit(cards: [:product_id, :opened, :closed, :opened_on_, :closed_on_])
    else # if they clicked 'I don't have any cards'
      {}
    end
  end
end
