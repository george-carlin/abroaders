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
  end
end
