class EligibilitiesController < AuthenticatedUserController
  onboard :eligibility, with: [:survey, :save_survey]

  def survey
    render cell(Nationality::Cell::Survey, current_account)
  end

  def save_survey
    run Person::EligibilitySurvey do
      redirect_to onboarding_survey_path
      return
    end
    raise 'this should never happen!'
  end
end
