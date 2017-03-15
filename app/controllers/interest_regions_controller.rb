class InterestRegionsController < AuthenticatedUserController
  onboard :regions_of_interest, with: [:survey, :save_survey]

  def survey
    run RegionsOfInterest::Operation::Survey
    render cell(RegionsOfInterest::Cell::Survey, result['regions'])
  end

  def save_survey
    run RegionsOfInterest::Operation::Survey::Save do
      redirect_to onboarding_survey_path
      return
    end
    raise 'this should never happen!' # always valid
  end
end
