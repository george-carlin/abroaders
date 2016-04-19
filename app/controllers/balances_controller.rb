class BalancesController < NonAdminController

  def survey
    @person = load_person
    redirect_if_already_completed_survey!
    @survey = BalancesSurvey.new(@person)
  end

  def save_survey
    @person = load_person
    redirect_if_already_completed_survey!
    @survey = BalancesSurvey.new(@person)
    # Bleeargh technical debt
    @survey.assign_attributes(balances_params)
    @survey.award_wallet_email = params[:balances_survey_award_wallet_email]
    if @survey.save
      redirect_to new_person_readiness_status_path(@person)
    else
      render "survey"
    end
  end

  private

  def balances_params
    params.permit(
      balances: [:currency_id, :value]
    ).fetch(:balances, [])
  end

  def load_person
    current_account.people.find(params[:person_id])
  end

  def redirect_if_already_completed_survey!
    if @person.onboarded_balances?
      redirect_to root_path
    end
  end
end
