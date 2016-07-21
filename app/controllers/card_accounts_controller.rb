class CardAccountsController < AuthenticatedUserController

  before_action :redirect_if_not_onboarded_travel_plans!,
                                      only: [:survey, :save_survey]
  before_action :redirect_if_account_type_not_selected!,
                                      only: [:survey, :save_survey]

  def index
    @people = current_account.people
    @card_recommendations = current_account.card_recommendations.includes(offer: { card: :currency }).visible
    @card_accounts_from_survey = current_account.card_accounts.from_survey

    @recommendation_notes = current_account.recommendation_notes

    current_account.card_recommendations.unseen.update_all(seen_at: Time.now)
  end


  def survey
    @person = load_person
    redirect_if_survey_is_inaccessible! and true
    @survey = CardsSurvey.new(person: @person)
  end

  def save_survey
    @person = load_person
    redirect_if_survey_is_inaccessible! and true
    # There's currently no way that survey_params can be invalid, so this
    # should never fail:
    CardsSurvey.new(survey_params.merge(person: @person)).save!
    redirect_to survey_person_balances_path(@person)
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  # WARNING non-strong-parameters hackery
  def survey_params
    if params[:cards_survey]
      { card_accounts: params[:cards_survey][:card_accounts] }
    else # if they clicked 'I don't have any cards'
      {}
    end
  end

  def redirect_if_survey_is_inaccessible!
    if !@person.onboarded_spending?
      redirect_to new_person_spending_info_path(@person) and return true
    elsif !@person.eligible? || @person.onboarded_cards?
      redirect_to survey_person_balances_path(@person) and return true
    end
  end


end
