# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < ApplicationController
  before_action :authenticate_account!

  def redirect_if_account_type_not_selected!
    redirect_to type_account_path unless current_account.onboarded_account_type?
  end
end
