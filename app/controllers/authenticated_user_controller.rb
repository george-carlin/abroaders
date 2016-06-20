# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!

  private

  def redirect_if_not_onboarded_travel_plans!
    redirect_to new_travel_plan_path unless current_account.onboarded_travel_plans?
  end

  def redirect_if_account_type_not_selected!
    redirect_to type_account_path unless current_account.onboarded_type?
  end
end
