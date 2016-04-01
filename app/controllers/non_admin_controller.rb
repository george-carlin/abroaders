# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < ApplicationController
  before_action :authenticate_account!

  before_action { redirect_to root_path if current_account.try(:admin?) }
  before_action :redirect_to_survey, unless: "current_account.onboarded?"

end
