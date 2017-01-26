class TravelPlansController < AuthenticatedUserController
  onboard :travel_plan, with: [:new, :create, :skip_survey], revisitable: true

  def index
    @travel_plans = current_account.travel_plans.includes_destinations
  end

  def new
    run TravelPlan::Operations::New
  end

  def create
    run TravelPlan::Operations::Create do
      flash[:success] = "Saved travel plan!"
      redirect_to travel_plans_path
      return
    end
    render "new"
  end

  def onboard
    raise "TODO"
    # onboarding = !current_account.onboarded?
    #   if onboarding
    #     redirect_to onboarding_survey_path
    #   else
    #     redirect_to travel_plans_path
    #   end
  end

  def edit
    raise 'temporarily disabled'
    # @travel_plan = EditTravelPlanForm.find(params[:id])
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
