class CardsController < AuthenticatedUserController
  onboard :owner_cards, :companion_cards, with: [:survey, :save_survey]

  def index
    # Unfortunately I can't figure out a better way of avoiding all the N+1 issues
    # without reloading the current account, since you can't call `includes`
    # after the account has already been loaded.
    account = Account.includes(
      people: [:account, { card_accounts: :card_product },
               actionable_card_recommendations: [:card_product, { offer: { card_product: :currency } }],],
    ).find(current_account.id)
    if account.actionable_card_recommendations?
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    unless current_admin
      account.card_recommendations.unseen.update_all(seen_at: Time.zone.now)
    end

    render cell(Card::Cell::Index, account)
  end

  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return
    survey = CardProduct::Survey.new(person: @person)
    render cell(Card::Cell::Survey, @person, form: survey)
  end

  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardProduct::Survey.new(survey_params.merge(person: @person)).save!
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
