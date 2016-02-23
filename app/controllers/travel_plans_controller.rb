class TravelPlansController < NonAdminController

  def index
    # TODO big N+1 queries problem here:
    @travel_plans = current_user.travel_plans.includes(:flights)
  end

  def new
    @travel_plan = current_user.travel_plans.new
    @travel_plan.flights.build
  end

  def create
    @travel_plan = current_user.travel_plans.new(travel_plan_params)
    # TODO replace this hardcoded value!
    @travel_plan.departure_date_range = Date.today..Date.tomorrow
    if @travel_plan.save
      flash[:success] = "Created travel plan!"
      redirect_to travel_plans_path
    else
      raise "TODO: handle errors"
    end
  end

  private

  def travel_plan_params
    params.require(:travel_plan).permit(
      :type, :no_of_passengers, flights_attributes: [:from_id, :to_id]
    )
  end

end
