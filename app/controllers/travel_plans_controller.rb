class TravelPlansController < NormalUserController

  def new
    @travel_plan = current_user.travel_plans.new
  end

end
