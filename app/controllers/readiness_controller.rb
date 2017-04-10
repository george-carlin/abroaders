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
