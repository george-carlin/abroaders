class EstimatesController < AuthenticatedUserController
  # 'travel_plan' survey page loads estimates via AJAX:
  onboard :travel_plan, with: :get

  def get
    render json: Estimates::FullEstimate.load(points_estimate_params)
  end

  private

  def points_estimate_params
    params.slice(:from_code, :to_code, :type, :no_of_passengers)
  end

end
