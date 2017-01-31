class AccountsController < AuthenticatedUserController
  onboard :account_type, with: [:type, :submit_type]

  # 'dashboard' lives under ApplicationController. This is because there are
  # two dashboards, the regular dashboard and the admin dashboard, but we can't
  # split it into two actions because they both live under the same path
  # (root_path)

  def type
    destination = current_account.travel_plans&.last&.flights&.first&.to
    # TODO convert to Trailblazer op
    @result = {
      'destination' => destination,
      'account'     => current_account,
    }
    # TODO provide :title, 'Select Account Type'
    render cell(Onboarding::Cell::Account::Type, @result)
  end

  def submit_type
    form = AccountTypeForm.new(account: current_account)
    form.update!(account_type_params)
    redirect_to onboarding_survey_path
  end

  private

  def account_type_params
    params.require(:account).permit(:type, :companion_first_name)
  end
end
