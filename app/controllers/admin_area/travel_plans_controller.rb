module AdminArea
  class TravelPlansController < AdminController
    def edit
      @travel_plan = AdminArea::EditTravelPlanForm.find(params[:id])
      @countries = load_counties
      @submit_url = submit_url(@travel_plan)
      render "travel_plans/edit"
    end

    def update
      @travel_plan = AdminArea::EditTravelPlanForm.find(params[:id])
      if @travel_plan.update_attributes(travel_plan_params)
        flash[:success] = "Travel plan for #{@travel_plan.owner_name} has been updated"
        redirect_to admin_person_path(@travel_plan.owner)
      else
        @countries = load_counties
        @submit_url = submit_url(@travel_plan)
        render "travel_plans/edit"
      end
    end

    private

    def travel_plan_params
      params.require(:travel_plan).permit(
        :type, :earliest_departure, :further_information,
        :no_of_passengers, :will_accept_economy, :will_accept_premium_economy,
        :will_accept_business_class, :will_accept_first_class, :from_id, :to_id
      )
    end

    def load_counties
      SelectableCountries.all
    end

    def submit_url(travel_plan)
      admin_travel_plan_path(travel_plan)
    end
  end
end
