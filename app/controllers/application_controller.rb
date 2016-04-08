class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      # Forget the survey redirection until we've got the individual forms working
      # etc TODO
      # redirect_to_survey and return unless current_account.onboarded?
      render "accounts/dashboard"
    end
  end

  def placeholder
    head :ok
  end

  protected

  # This will only ever be called from ApplicationController#dashboard, or from
  # NonAdminController and its subclasses, since it only applies to logged-in
  # users who aren't Admins (i.e. who are Accounts). application#dashboard is
  # the only path that a logged in Account might visit that doesn't live under
  # NonAdminController (and it can't live under that controller because the
  # path in question is root_path, which for obvious reasons may be visited by
  # anybody)
  def redirect_to_survey
    {
      # Value of account.onboarding_stage =>
      #       the path to redirect to if they're at this stage
      "travel_plans"            => survey_travel_plan_path,
      "passengers"              => survey_passengers_path,
      "spending"                => survey_spending_path,
      "main_passenger_cards"    => survey_card_accounts_path(:main),
      "companion_cards"         => survey_card_accounts_path(:companion),
      "main_passenger_balances" => survey_balances_path(:main),
      "companion_balances"      => survey_balances_path(:companion),
      "readiness"               => survey_readiness_path
    }.each do |stage, path|
      if current_account.onboarding_stage == stage && request.path != path
        redirect_to path and return true
      end
    end
    false
  end

end
