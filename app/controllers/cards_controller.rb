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
    form Card::Update
  end

  def update
    run Card::Update do |_op|
      flash[:success] = 'Updated card'
      return redirect_to cards_path
    end
    render :edit
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

  def survey_params
    if params.key?(:cards_survey)
      params.require(:cards_survey).permit(cards: [:product_id, :opened, :closed, :opened_at_, :closed_at_])
    else # if they clicked 'I don't have any cards'
      {}
    end
  end
end
