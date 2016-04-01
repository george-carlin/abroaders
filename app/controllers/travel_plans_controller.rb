class TravelPlansController < NonAdminController

  def index
    @travel_plans = current_account.travel_plans.includes(
      flights: {
        # Is there really not a better way of doing this?
        from: { parent: { parent: { parent: :parent } } },
        to:   { parent: { parent: { parent: :parent } } }
      }
    )
  end

  def new
    raise "not yet implemented"
    # This is the old stuff and has been replaced with the system that
    # currently only lives on the travel plan survey.
    @travel_plan = current_account.travel_plans.new
    @travel_plan.flights.build
  end

  def create
    raise "not yet implemented"
    # This is the old stuff and has been replaced with the system that
    # currently only lives on the travel plan survey.
    @travel_plan = current_account.travel_plans.new(travel_plan_params)
    @travel_plan.flights.each_with_index { |f, i| f.position = i }
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
