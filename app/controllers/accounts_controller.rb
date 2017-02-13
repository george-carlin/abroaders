class AccountsController < AuthenticatedUserController
  onboard :account_type, with: [:type, :submit_type]

  # 'dashboard' lives under ApplicationController. This is because there are
  # two dashboards, the regular dashboard and the admin dashboard, but we can't
  # split it into two actions because they both live under the same path
  # (root_path)

  def type
    run Account::Operation::Type
    # TODO provide :title, 'Select Account Type'
    render cell(Onboarding::Cell::Account::Type, result)
  end

  def submit_type
    run Account::Operation::Type::Onboard
    redirect_to onboarding_survey_path
  end
end
