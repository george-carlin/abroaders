class SpendingInfosController < NonAdminController

  def new
    @person = load_person
    redirect_if_already_added_spending!
    @spending_info = SpendingSurvey.new(@person)
  end

  def create
    @person = load_person
    redirect_if_already_added_spending!
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
      :monthly_spending_usd,
      :will_apply_for_loan,
    )
  end

  def redirect_if_already_added_spending!
    if @person.onboarded_spending?
      redirect_to survey_person_card_accounts_path(@person)
    end
  end

end
