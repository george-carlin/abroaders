class SpendingInfosController < NonAdminController

  def new
    @person = load_person
    redirect_if_already_added_spending!
    @spending_info = @person.build_spending_info
  end

  def create
    @person = load_person
    redirect_if_already_added_spending!
    @spending_info = @person.build_spending_info(spending_info_params)
    if @spending_info.save
      redirect_to survey_person_card_accounts_path(@person)
    else
      render "new"
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def spending_info_params
    params.require(:spending_info).permit(
      :business_spending_usd,
      :citizenship,
      :credit_score,
      :has_business,
      :will_apply_for_loan,
    )
  end

  def redirect_if_already_added_spending!
    if @person.onboarded_spending?
      redirect_to survey_person_card_accounts_path(@person)
    end
  end

end
