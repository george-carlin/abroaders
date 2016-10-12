class InterestRegionsController < AuthenticatedUserController
  def survey
    @regions = Region.all
    @interest_regions = InterestRegionsSurveyForm.new(account: current_account)
  end

  def save_survey
    @interest_regions = InterestRegionsSurveyForm.new(account: current_account)
    # not supposed to be invalid
    @interest_regions.update!(interest_regions_survey_params)
    redirect_to root_path
  end

  private

  def interest_regions_survey_params
    if params.has_key?(:interest_regions_survey)
      params.require(:interest_regions_survey).permit(regions: [:region_id, :selected])
    else # if user doesn't select anything
      {}
    end
  end
end
