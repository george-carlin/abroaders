class EstimatesController < ApplicationController
  # 'travel_plan' survey and 'admin/accounts#show' pages load estimates via AJAX:

  def get
    render json: Estimates::FullEstimate.load(points_estimate_params)
  end

  private

  def points_estimate_params
    params.slice(:from_code, :to_code, :type, :no_of_passengers)
  end
end
