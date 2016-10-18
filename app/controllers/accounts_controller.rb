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
    redirect_to current_account.onboarding_survey.current_page.path
  end

  def create_couples_account
    @couples_account = CouplesAccountForm.new(couples_account_params)
    @couples_account.account = current_account
    # The front-end should prevent invalid data from being submitted. If they
    # bypass the JS, fuck 'em.
    @couples_account.save!
    track_account_type_intercom_event!
    redirect_to current_account.onboarding_survey.current_page.path
  end

  private

  def solo_account_params
    params.require(:solo_account).permit(:monthly_spending_usd, :eligible, :phone_number)
  end

  def couples_account_params
    params.require(:couples_account).permit(
      :monthly_spending_usd, :companion_first_name, :eligibility, :phone_number,
    )
  end

  def track_account_type_intercom_event!
    track_intercom_event("obs_account_type")
  end
end
