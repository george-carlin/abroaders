module AdminArea
  class TravelPlansController < AdminController
    def edit
      render(text: "temporarily disabled") && return
      # @travel_plan = AdminArea::EditTravelPlanForm.find(params[:id])
      # render "travel_plans/edit"
    end

    def update
      render(text: "temporarily disabled") && return
      # @travel_plan = AdminArea::EditTravelPlanForm.find(params[:id])
      # if @travel_plan.update_attributes(travel_plan_params)
      #   flash[:success] = "Travel plan for #{@travel_plan.owner_name} has been updated"
      #   redirect_to admin_person_path(@travel_plan.owner)
      # else
      #   render "travel_plans/edit"
      # end
    end

    private

    def travel_plan_params
      params.require(:travel_plan).permit(
        :type, :departure_date, :return_date, :further_information,
        :no_of_passengers, :will_accept_economy, :will_accept_premium_economy,
        :will_accept_business_class, :will_accept_first_class, :from_id, :to_id,
      )
    end
  end
end
