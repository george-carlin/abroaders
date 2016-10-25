# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_not_onboarded!

  private

  def track_intercom_event(_event_name)
    raise "intercom event tracking temporarily disabled"
    # IntercomJobs::TrackEvent.perform_later(
    #   email:      current_account.email,
    #   event_name: event_name,
    # )
  end
end
