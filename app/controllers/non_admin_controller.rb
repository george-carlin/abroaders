# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class NonAdminController < ApplicationController
  before_action :authenticate_account!

  # Forget the survey redirection until we've got the individual forms working
  # etc TODO
  # before_action :redirect_to_survey, unless: "current_account.onboarded?"

end
