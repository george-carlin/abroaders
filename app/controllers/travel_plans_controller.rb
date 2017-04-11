class TravelPlansController < AuthenticatedUserController
  onboard :travel_plan, with: [:new, :create, :skip_survey], revisitable: true

  def index
    travel_plans = current_account.travel_plans.includes_destinations
    render cell(TravelPlan::Cell::Index, travel_plans)
  end

  def new
    run TravelPlan::New
  end

  def create
    if current_account.onboarded?
      run TravelPlan::Create do
        flash[:success] = "Saved travel plan!"
        redirect_to travel_plans_path
        return
      end
    else
      run TravelPlan::Onboard do
        flash[:success] = "Saved your first travel plan!"
        redirect_to onboarding_survey_path
        return
      end
    end
    render 'new'
  end

  def edit
    run TravelPlan::Edit
    # initialize 'from' and 'to' correctly:
    @form.prepopulate!
  end

  def update
    run TravelPlan::Update do
      flash[:success] = 'Updated travel plan!'
      redirect_to travel_plans_path
      return
    end
    render 'edit'
  end

  def destroy
    run TravelPlan::Destroy do
      flash[:success] = 'Deleted travel plan!'
      redirect_to travel_plans_path
    end
  end

  def skip_survey
    Account::Onboarder.new(current_account).skip_travel_plan!
    redirect_to type_account_path
  end
end
