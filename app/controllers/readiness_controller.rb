# 'Readiness' is a concept that only really exists on the onboarding survey.
# When a user says they're "ready", it just creates a recommendation request.
# These rec requests aren't any different from the requests they can create
# post-onboarding. It's just a different interface for creating them (that the
# user will only ever see once.)
#
# The word 'readiness' is mostly a legacy thing. Before we introduced the
# concept of a 'rec request', people had a boolean attribute called 'ready'
# that in theory would have continually toggled between true and false,
# although we never finished fully implementing it. So if you see the word
# 'ready' lingering around the codebase, it's probably a leftover from those
# days.
class ReadinessController < AuthenticatedUserController
  onboard :readiness, with: [:survey, :save_survey]

  def survey
    render cell(Readiness::Cell::Survey, current_account)
  end

  def save_survey
    run(Readiness::Survey)
    redirect_to onboarding_survey_path
  end
end
