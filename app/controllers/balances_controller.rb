class BalancesController < NonAdminController

  def survey
    @person = load_person
    @survey = BalancesSurvey.new(@person)
  end

  def save_survey
    @person = load_person
    @survey = BalancesSurvey.new(@person)
    if @survey.update_attributes(balances_params)
      render plain: "TODO: where to redirect to?"
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
end
