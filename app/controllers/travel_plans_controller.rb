class TravelPlansController < AuthenticatedUserController
  onboard :travel_plan, with: [:new, :create, :skip_survey], revisitable: true

  def index
    @travel_plans = current_account.travel_plans.includes_destinations
  end

  def new
    @travel_plan = NewTravelPlanForm.new(account: current_account)
  end

  def create
    onboarding = !current_account.onboarded?
    @travel_plan = NewTravelPlanForm.new(account: current_account)
    if @travel_plan.update_attributes(travel_plan_params)
      if onboarding
        track_intercom_event("obs_travel_plan")
        redirect_to onboarding_survey_path
      else
        redirect_to travel_plans_path
      end
    else
      render "new"
    end
  end

  def edit
    @travel_plan = EditTravelPlanForm.find(params[:id])
  end

  def update
    @travel_plan = EditTravelPlanForm.find(params[:id])
    if @travel_plan.update_attributes(travel_plan_params)
      flash[:success] = "Updated travel plan"
      redirect_to travel_plans_path
    else
      render "edit"
    end
  end

  def skip_survey
    AccountOnboarder.new(current_account).skip_travel_plan!
    IntercomJobs::TrackEvent.perform_later(
      email:      current_account.email,
      event_name: "obs_travel_plan",
    )
    redirect_to type_account_path
  end

  private

  def travel_plan_params
    params.require(:travel_plan).permit(
      :type, :departure_date, :return_date, :further_information,
      :no_of_passengers, :will_accept_economy, :will_accept_premium_economy,
      :will_accept_business_class, :will_accept_first_class, :from_id, :to_id,
    )
  end

  def load_travel_plan
    current_account.travel_plans.find(params[:id])
  end
end
