class SpendingInfosController < NonAdminController
  before_action :redirect_if_not_onboarded_travel_plans!
  before_action :redirect_if_account_type_not_selected!

  def new
    @person = load_person
    redirect_if_inaccessible! and return
    @spending_info = SpendingSurvey.new(@person)
  end

  def create
    @person = load_person
    redirect_if_inaccessible! and return
    @spending_info = SpendingSurvey.new(@person)
    if @spending_info.update_attributes(spending_survey_params)
      current_account.save!
      redirect_to survey_person_card_accounts_path(@person)
    else
      render "new"
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def spending_survey_params
    params.require(:spending_info).permit(
      :business_spending_usd,
      :credit_score,
      :has_business,
      :will_apply_for_loan,
    )
  end

  def redirect_if_inaccessible!
    if !@person.eligible_to_apply?
      redirect_to survey_person_balances_path(@person) and return true
    elsif @person.onboarded_spending?
      redirect_to survey_person_card_accounts_path(@person) and return true
    end
  end

end
