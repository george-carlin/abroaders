class AccountsController < NonAdminController
  before_action :redirect_if_not_onboarded_travel_plans!
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
    if @solo_account.eligible_to_apply?
      redirect_to new_person_spending_info_path(@solo_account.person)
    else
      redirect_to survey_person_balances_path(@solo_account.person)
    end
  end

  def create_partner_account
    @partner_account = PartnerAccountForm.new(partner_account_params)
    @partner_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @partner_account.save!
    if @partner_account.person_0_eligible_to_apply?
      redirect_to new_person_spending_info_path(@partner_account.person_0)
    elsif @partner_account.person_1_eligible_to_apply?
      redirect_to new_person_spending_info_path(@partner_account.person_1)
    else
      redirect_to survey_person_balances_path(@partner_account.person_0)
    end
  end

  private

  def redirect_if_not_onboarded_travel_plans!
    if !current_account.onboarded_travel_plans?
      redirect_to new_travel_plan_path
    end
  end

  def redirect_if_type_already_given!
    if current_account.onboarded_type?
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
