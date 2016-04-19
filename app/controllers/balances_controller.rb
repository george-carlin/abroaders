class BalancesController < NonAdminController
  before_action :redirect_if_account_type_not_selected!

  def survey
    @person = load_person
    redirect_if_already_completed_survey! and return
    @survey = BalancesSurvey.new(@person)
  end

  def save_survey
    @person = load_person
    redirect_if_already_completed_survey! and return
    @survey = BalancesSurvey.new(@person)
    # Bleeargh technical debt
    @survey.assign_attributes(balances_params)
    @survey.award_wallet_email = params[:balances_survey_award_wallet_email]
    if @survey.save
      redirect_to after_save_path
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
      redirect_to root_path and return true
    end
  end

  def after_save_path
    if @person.eligible_to_apply?
      new_person_readiness_status_path(@person)
    elsif !@person.main? || !(partner = current_account.companion)
      root_path
    elsif partner.eligible_to_apply?
      new_person_spending_info_path(partner)
    else
      survey_person_balances_path(partner)
    end
  end

  def redirect_if_account_type_not_selected!
    redirect_to type_account_path unless current_account.onboarded_account_type?
  end
end
