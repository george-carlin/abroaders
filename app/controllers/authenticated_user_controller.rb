# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_onboarding_survey_incomplete!

  private

  def redirect_if_onboarding_survey_incomplete!
    survey = current_account.onboarding_survey
    routes_map = survey.routes_map

    if survey.complete?
      redirect_to root_path if request_to_onboarding_survey?(routes_map)
    else
      redirect_to survey.current_path if request.method == "GET" && request.path != survey.current_path
    end
  end

  def request_to_onboarding_survey?(routes_map)
    routes_map.map{ |name, options| return true if options[:path] == request.path && !options[:revisitable] }
    false
  end

  def track_intercom_event(event_name)
    IntercomJobs::TrackEvent.perform_later(
      email:      current_account.email,
      event_name: event_name,
    )
  end
end
