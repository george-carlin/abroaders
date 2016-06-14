class CardAccountsController < NonAdminController

  before_action :redirect_if_not_onboarded_travel_plans!,
                                      only: [:survey, :save_survey]
  before_action :redirect_if_account_type_not_selected!,
                                      only: [:survey, :save_survey]

  def index
    current_account.people.each do |person|
      new_cards = person.card_accounts.never_seen
      new_cards.each do |card_account|
        card_account.seen_at = Time.now()
        card_account.save!
      end
    end
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
    { card_accounts: params[:cards_survey][:card_accounts] }
  end

  def redirect_if_survey_is_inaccessible!
    if !@person.onboarded_spending?
      redirect_to new_person_spending_info_path(@person) and return true
    elsif !@person.eligible_to_apply? || @person.onboarded_cards?
      redirect_to survey_person_balances_path(@person) and return true
    end
  end


end
