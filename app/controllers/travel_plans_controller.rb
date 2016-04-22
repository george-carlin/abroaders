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
    @travel_plan = NewTravelPlanForm.new(current_account)
    @countries   = load_countries
  end

  def create
    onboarding = !current_account.onboarded_travel_plans?
    @travel_plan = NewTravelPlanForm.new(current_account)
    if @travel_plan.update_attributes(travel_plan_params)
      redirect_to onboarding ? type_account_path : travel_plans_path
    else
      @countries = load_countries
      render "new"
    end
  end

  def edit
    @travel_plan = EditTravelPlanForm.new(load_travel_plan)
    @countries   = load_countries
  end

  def update
    @travel_plan = EditTravelPlanForm.new(load_travel_plan)
    if @travel_plan.update_attributes(travel_plan_params)
      flash[:success] = "Updated travel plan"
      redirect_to travel_plans_path
    else
      @countries = load_countries
      render "edit"
    end
  end

  private

  def travel_plan_params
    params.require(:travel_plan).permit(
      :type, :from_id, :to_id, :earliest_departure, :further_information,
      :no_of_passengers, :will_accept_economy, :will_accept_premium_economy,
      :will_accept_business_class, :will_accept_first_class
    )
  end

  def load_countries
    Destination.country.order("name ASC")
  end

  def load_travel_plan
    current_account.travel_plans.find(params[:id])
  end

end
