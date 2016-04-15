class AccountsController < NonAdminController

  def type
    @travel_plan     = current_account.travel_plans.last
    @solo_account    = SoloAccountForm.new
    @partner_account = PartnerAccountForm.new
    @person_0        = current_account.people.first
  end

  def select_type
    @solo_account = SoloAccountForm.new(solo_account_params)
  end

  private

  def solo_account_params
    params.require(:solo_account).permit(:monthly_spending_usd, :eligible_to_apply)
  end

end
