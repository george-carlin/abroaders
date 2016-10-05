class EligibilitiesController < AuthenticatedUserController
  def survey
    @survey = EligibilitySurvey.new(
      eligible: current_account.has_companion? ? "both" : "owner",
    )
  end

  def save_survey
    @survey = EligibilitySurvey.new(account: current_account)
    @survey.update!(eligibility_survey_params)
    redirect_to current_account.onboarding_survey.current_page.path
  end

  private

  def eligibility_survey_params
    params.require(:eligibility_survey).permit(:eligible)
  end
end
