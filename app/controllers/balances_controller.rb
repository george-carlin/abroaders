class BalancesController < AuthenticatedUserController
  onboard :owner_balances, :companion_balances, with: [:survey, :save_survey]

  # GET /balances
  def index
    run Balance::Operation::Index
    render cell(Balance::Cell::Index, result, flash: flash)
  end

  # GET /people/:person_id/balances/new
  def new
    run Balance::Operation::New
    # TODO TRB convert view to cell
  end

  # POST /people/:person_id/balances
  def create
    run Balance::Operation::Create do
      flash[:success] = 'Created balance!'
      return redirect_to balances_path
    end
    # TODO TRB convert view to cell
    render 'new'
  end

  # PUT/PATCH /balances/:id
  def update
    run Balance::Operation::Update do
      @valid = true
    end
    respond_to do |f|
      f.js
    end
  end

  # DELETE /balances/:id
  def destroy
    run Balance::Operation::Destroy do
      flash[:success] = 'Destroyed balance!'
      redirect_to balances_path
    end
  end

  # GET /people/:person_id/balances/survey
  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    @survey     = BalancesSurvey.new(person: @person)
    @currencies = Currency.survey.order(name: :asc)
  end

  # POST /people/:person_id/balances/survey
  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type!
    @survey = BalancesSurvey.new(person: @person)
    # Bleeargh technical debt
    @survey.assign_attributes(survey_params)
    @survey.award_wallet_email = params[:balances_survey_award_wallet_email]
    if @survey.save
      redirect_to onboarding_survey_path
    else
      render "survey"
    end
  end

  private

  def survey_params
    params.permit(
      balances: [:currency_id, :value],
    ).fetch(:balances, [])
  end

  def load_person
    current_account.people.find(params[:person_id])
  end
end
