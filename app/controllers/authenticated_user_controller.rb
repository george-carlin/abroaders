# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_not_onboarded!

  private

  # Pass these options by default into Trailblazer operations when calling
  # them with 'run'
  def _run_options(options)
    options['account'] = current_account
    if params[:person_id]
      person = current_account.people.find(params[:person_id])
      options['person'] = person
    end
    options
  end

  def run(*args)
    @_run_called = true
    super
  end
end
