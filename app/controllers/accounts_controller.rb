class AccountsController < AuthenticatedUserController
  onboard :account_type, with: [:type, :submit_type]

  # 'dashboard' lives under ApplicationController. This is because there are
  # two dashboards, the regular dashboard and the admin dashboard, but we can't
  # split it into two actions because they both live under the same path
  # (root_path)

  def type
    @destination = current_account.travel_plans&.last&.flights&.first&.to
    @owner       = current_account.owner
  end

  def submit_type
    form = AccountTypeForm.new(account: current_account)
    form.update!(account_type_params)
    track_account_type_intercom_event!
    redirect_to onboarding_survey_path
  end

  private

  def account_type_params
    params.require(:account).permit(:type, :companion_first_name).to_h
  end

  def track_account_type_intercom_event!
    track_intercom_event("obs_account_type")
  end

end
