# Superclass for all controllers whose actions are intended to be used by
# logged-in 'normal', non-admin accounts.
class AuthenticatedUserController < ApplicationController
  before_action :authenticate_account!
  before_action :redirect_if_onboarding_survey_incomplete!
  include OnboardingSurveyHelper

  private

  def redirect_if_onboarding_survey_incomplete!
    survey = current_account.onboarding_survey
    if survey.incomplete? && !current_survey_path?(request.path)
      redirect_to onboarding_survey_path
    end
  end

  def track_intercom_event(event_name)
    IntercomJobs::TrackEvent.perform_later(
      email:      current_account.email,
      event_name: event_name
    )
  end
end
