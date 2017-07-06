class TravelPlansController < AuthenticatedUserController
  onboard :travel_plan, with: [:new, :create, :skip_survey], revisitable: true

  def index
    travel_plans = current_account.travel_plans.includes_destinations
    render cell(TravelPlan::Cell::Index, travel_plans)
  end

  def new
    run TravelPlan::New
    render cell(TravelPlan::Cell::New, @model, form: @form)
  end

  def create
    if current_account.onboarded?
      op = TravelPlan::Create
      success_msg = 'Saved travel plan!'
      success_redirect = travel_plans_path
    else
      op = TravelPlan::Onboard
      success_msg = 'Saved your first travel plan!'
      success_redirect = onboarding_survey_path
    end

    run op do
      flash[:success] = success_msg
      redirect_to success_redirect
      return
    end
    render cell(TravelPlan::Cell::New, @model, form: @form)
  end

  def edit
    run TravelPlan::Edit
    # initialize 'from' and 'to' correctly:
    @form.prepopulate!
    render cell(TravelPlan::Cell::Edit, @model, form: @form)
  end

  def update
    run TravelPlan::Update do
      flash[:success] = 'Updated travel plan!'
      redirect_to travel_plans_path
      return
    end
    render cell(TravelPlan::Cell::Edit, @model, form: @form)
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
