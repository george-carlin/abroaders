class EstimatesController < AuthenticatedUserController
  skip_before_action :redirect_if_onboarding_survey_incomplete!

  def get
    render json: Estimates::FullEstimate.load(points_estimate_params)
  end

  private

  def points_estimate_params
    params.slice(:from_code, :to_code, :type, :no_of_passengers)
  end

end
