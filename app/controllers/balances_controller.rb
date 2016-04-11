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
    if @survey.update_attributes(balances_params)
      if current_account.people.count > 1
        redirect_to survey_readiness_path
      else
        redirect_to new_companion_path
      end
    else
      render "survey"
    end
  end

  private

  def balances_params
    params.permit(balances: [:currency_id, :value]).fetch(:balances, [])
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
