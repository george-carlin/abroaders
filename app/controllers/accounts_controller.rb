class AccountsController < NonAdminController
  before_action :redirect_if_type_already_given!

  def type
    @travel_plan     = current_account.travel_plans.last
    @solo_account    = SoloAccountForm.new
    @partner_account = PartnerAccountForm.new
    @person_0        = current_account.people.first
  end

  def create_solo_account
    @solo_account = SoloAccountForm.new(solo_account_params)
    @solo_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @solo_account.save!
    redirect_to new_person_spending_info_path(current_account.people.first)
  end

  def create_partner_account
    @partner_account = PartnerAccountForm.new(partner_account_params)
    @partner_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @partner_account.save!
    redirect_to new_person_spending_info_path(current_account.people.first)
  end

  private

  def redirect_if_type_already_given!
    if current_account.has_chosen_account_type?
      redirect_to new_person_spending_info_path(current_account.people.first)
    end
  end

  def solo_account_params
    params.require(:solo_account).permit(:monthly_spending_usd, :eligible_to_apply)
  end

  def partner_account_params
    params.require(:partner_account).permit(
      :monthly_spending_usd, :partner_first_name, :eligibility
    )
  end

end
