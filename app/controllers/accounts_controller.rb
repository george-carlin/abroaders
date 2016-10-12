class AccountsController < AuthenticatedUserController

  # 'dashboard' lives under ApplicationController. This is because there are
  # two dashboards, the regular dashboard and the admin dashboard, but we can't
  # split it into two actions because they both live under the same path
  # (root_path)

  def type
    @destination = current_account.travel_plans&.last&.flights&.first&.to
    @owner       = current_account.owner
  end

  def create_solo_account
    @solo_account = SoloAccountForm.new(solo_account_params)
    @solo_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @solo_account.save!
    track_account_type_intercom_event!
    redirect_to onboarding_survey.current_path
  end

  def create_partner_account
    @partner_account = PartnerAccountForm.new(partner_account_params)
    @partner_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @partner_account.save!
    track_account_type_intercom_event!
    redirect_to onboarding_survey.current_path
  end

  private

  def solo_account_params
    # Virtus will call `to_hash` on the passed attributes, but this method
    # is deprecated on ActionController::Parameters; call `to_h` instead:
    params.require(:solo_account).permit(:monthly_spending_usd, :eligible, :phone_number).to_h
  end

  def partner_account_params
    # Virtus will call `to_hash` on the passed attributes, but this method
    # is deprecated on ActionController::Parameters; call `to_h` instead:
    params.require(:partner_account).permit(
      :monthly_spending_usd, :partner_first_name, :eligibility, :phone_number
    ).to_h
  end

  def track_account_type_intercom_event!
    track_intercom_event("obs_account_type")
  end

end
