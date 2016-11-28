class CardsController < AuthenticatedUserController
  onboard :owner_cards, :companion_cards, with: [:survey, :save_survey]

  def index
    @people = current_account.people
    @recommendations = current_account.card_recommendations\
                                      .includes(:product, offer: { product: :currency })\
                                      .visible
    @cards_from_survey = current_account.cards\
                                        .includes(:product, :offer)\
                                        .from_survey
    if current_account.card_recommendations.unresolved.count > 0
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    @recommendation_notes = current_account.recommendation_notes

    current_account.card_recommendations.unseen.each do |c|
      c.update!(seen_at: Time.zone.now)
    end
  end

  def edit
    @card = EditCardForm.find(current_account, params[:id])
  end

  def update
    @card = EditCardForm.find(current_account, params[:id])

    if @card.update(card_params)
      flash[:success] = 'Updated card'
      redirect_to cards_path
    else
      render :edit
    end
  end

  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    @survey = Card::Product::Survey.new(person: @person)
  end

  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    Card::Product::Survey.new(survey_params.merge(person: @person)).save!
    # track_intercom_event("obs_cards_#{@person.type[0..2]}")
    redirect_to onboarding_survey_path
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def card_params
    params.require(:card).permit(:closed, :closed_year, :closed_month, :opened_year, :opened_month)
  end

  def survey_params
    if params.key?(:cards_survey)
      params.require(:cards_survey).permit(cards: [:product_id, :opened, :closed, :opened_at_, :closed_at_])
    else # if they clicked 'I don't have any cards'
      {}
    end
  end
end