class TravelPlansController < AuthenticatedUserController
  before_action :redirect_if_on_other_survey_page, only: [:new, :create]

  def index
    @travel_plans = current_account.travel_plans.includes_destinations
  end

  def new
    @travel_plan = NewTravelPlanForm.new(account: current_account)
    @countries   = load_countries
  end

  def create
    onboarding = !current_account.onboarded_travel_plans?
    @travel_plan = NewTravelPlanForm.new(account: current_account)
    if @travel_plan.update_attributes(travel_plan_params)
      redirect_to onboarding ? type_account_path : travel_plans_path
    else
      @countries = load_countries
      render "new"
    end
  end

  def edit
    @travel_plan = EditTravelPlanForm.find(params[:id])
    @countries   = load_countries
  end

  def update
    @travel_plan = EditTravelPlanForm.find(params[:id])
    if @travel_plan.update_attributes(travel_plan_params)
      flash[:success] = "Updated travel plan"
      redirect_to travel_plans_path
    else
      @countries = load_countries
      render "edit"
    end
  end

  def skip_survey
    if current_account.onboarded_travel_plans
      redirect_to type_account_path and return
    end
    current_account.onboarded_travel_plans = true
    current_account.save!
    IntercomJobs::TrackEvent.perform_later(
      email:      current_account.email,
      event_name: "obs_travel_plan"
    )
    redirect_to type_account_path
  end

  private

  def travel_plan_params
    params.require(:travel_plan).permit(
      :type, :earliest_departure, :further_information,
      :no_of_passengers, :will_accept_economy, :will_accept_premium_economy,
      :will_accept_business_class, :will_accept_first_class, :from_id, :to_id
    )
  end

  def redirect_if_on_other_survey_page
    if current_account.onboarded_travel_plans? && !current_account.onboarded?
      redirect_to type_account_path
    end
  end

  def load_countries
    countries = Destination.country.order("name ASC").to_a

    if ha = countries.detect { |c| c.name == "Hawaii" }
      countries.delete(ha)
      countries.unshift(ha)
    end

    if al = countries.detect { |c| c.name == "Alaska" }
      countries.delete(al)
      countries.unshift(al)
    end

    if us = countries.detect { |c| c.name == "United States (Continental 48)" }
      countries.delete(us)
      countries.unshift(us)
    end

    countries
  end

  def load_travel_plan
    current_account.travel_plans.find(params[:id])
  end

end
