class CardAccountsController < AuthenticatedUserController
  def index
    @people = current_account.people
    @card_recommendations = current_account.card_recommendations\
                                           .includes(:card, offer: { card: :currency })\
                                           .visible
    @card_accounts_from_survey = current_account.card_accounts\
                                                .includes(:card, :offer)\
                                                .from_survey
    if current_account.card_recommendations.unresolved.count.positive?
      cookies[:recommendation_timeout] = { value: "timeout", expires: 24.hours.from_now }
    end

    @recommendation_notes = current_account.recommendation_notes

    current_account.card_recommendations.unseen.update_all(seen_at: Time.now)
  end

  def new
    redirect_if_ineligible && return

    card = Card.find(params[:card_id])
    @card_account = NewCardAccountForm.new(card: card)
  end

  def create
    redirect_if_ineligible && return

    card = Card.find(params[:card_id])
    @card_account = NewCardAccountForm.new(card_card_account_params.merge(card: card))

    @card_account.save!
    flash[:success] = "Created card"
    redirect_to card_accounts_path
  end

  def edit
    @card_account = EditCardAccountForm.find(params[:id])
  end

  def update
    @card_account = EditCardAccountForm.find(params[:id])

    @card_account.update!(card_account_params)
    flash[:success] = "Updated card"
    redirect_to card_accounts_path
  end

  def survey
    @person = load_person
    @survey = CardsSurvey.new(person: @person)
  end

  def save_survey
    @person = load_person
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardsSurvey.new(survey_params.merge(person: @person)).save!
    track_intercom_event("obs_cards_#{@person.type[0..2]}")
    redirect_to current_account.onboarding_survey.current_page.path
  end

  def choose_card
    redirect_if_ineligible && return
    @card_account = NewCardAccountForm.new
  end

  private

  def redirect_if_ineligible
    redirect_to root_path unless current_account.eligible?
  end

  def load_person
    current_account.people.find(params[:person_id])
  end

  def card_card_account_params
    params.require(:card_card_account).permit(:person_id, :closed, :closed_year, :closed_month, :opened_year, :opened_month).to_h
  end

  def card_account_params
    params.require(:card_account).permit(:person_id, :closed, :closed_year, :closed_month, :opened_year, :opened_month).to_h
  end

  def survey_params
    if params.key?(:cards_survey)
      params.require(:cards_survey).permit(card_accounts: [:card_id, :opened, :closed, :opened_at_, :closed_at_]).to_h
    else # if they clicked 'I don't have any cards'
      {}
    end
  end
end
