class EligibilitiesController < AuthenticatedUserController

  def survey
    @survey = EligibilitySurvey.new(
      eligible: current_account.has_companion? ? "both" : "owner"
    )
  end

end
