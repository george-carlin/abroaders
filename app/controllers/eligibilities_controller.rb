class EligibilitiesController < AuthenticatedUserController
  onboard :eligibility, with: [:survey, :save_survey]

  def survey
    @survey = EligibilitySurvey.new(
      eligible: current_account.has_companion? ? "both" : "owner"
    )
  end

  def save_survey
    @survey = EligibilitySurvey.new(account: current_account)
    @survey.update!(eligibility_survey_params)
    redirect_to onboarding_survey_path
  end

  private

  def eligibility_survey_params
    params.require(:eligibility_survey).permit(:eligible)
  end

end
