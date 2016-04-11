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
    @form      = NewTravelPlanForm.new(current_account)
    @countries = load_countries
  end

  def create
    @form = NewTravelPlanForm.new(current_account)
    if @form.update_attributes(travel_plan_params)
      if current_account.travel_plans.count > 1
        redirect_to travel_plans_path
      else
        # If this is the first travel plan they've added, it means they've just
        # signed up, so need to complete the rest of the onboarding process:
        redirect_to new_person_spending_info_path(current_account.people.first)
      end
    else
      @countries = load_countries
      render "new"
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

  def after_create_path
  end

end
