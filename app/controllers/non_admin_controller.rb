# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < ApplicationController
  before_action :authenticate_account!

  before_action { redirect_to root_path if current_account.try(:admin?) }
  before_action :redirect_to_survey, unless: "current_account.onboarded?"

  protected

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
        redirect_to path and return
      end
    end
  end
end
