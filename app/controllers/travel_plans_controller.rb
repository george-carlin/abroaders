class TravelPlansController < AuthenticatedUserController
  onboard :travel_plan, with: [:new, :create, :skip_survey], revisitable: true

  def index
    @travel_plans = current_account.travel_plans.includes_destinations
  end

  def new
    run TravelPlan::Operations::New
  end

  def create
    if current_account.onboarded?
      run TravelPlan::Operations::Create do
        flash[:success] = "Saved travel plan!"
        redirect_to travel_plans_path
        return
      end
    else
      run TravelPlan::Operations::Onboard do
        flash[:success] = "Saved your first travel plan!"
        redirect_to onboarding_survey_path
        return
      end
    end
    render "new"
  end

  def edit
    run TravelPlan::Operations::Edit
  end

  def update
    raise 'temporarily disabled'
    # @travel_plan = EditTravelPlanForm.find(params[:id])
    # if @travel_plan.update_attributes(travel_plan_params)
    #   flash[:success] = "Updated travel plan"
    #   redirect_to travel_plans_path
    # else
    #   render "edit"
    # end
  end

  def skip_survey
    Account::Onboarder.new(current_account).skip_travel_plan!
    redirect_to type_account_path
  end
end
