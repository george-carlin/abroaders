class SpendingInfosController < NonAdminController

  def new
    @person = load_person
    @spending_info = @person.build_spending_info
  end

  def create
    @person = load_person
    @spending_info = @person.build_spending_info(spending_info_params)
    if @spending_info.save
      render plain: "TODO: where to redirect to?"
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

end
