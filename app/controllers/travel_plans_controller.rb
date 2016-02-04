class TravelPlansController < NonAdminController

  def new
    @travel_plan = TravelPlan.new #NewTravelPlan.new(type: :return)
    @travel_plan.legs.build
  end

end
