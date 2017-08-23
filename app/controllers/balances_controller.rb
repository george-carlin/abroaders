class BalancesController < AuthenticatedUserController
  onboard :owner_balances, :companion_balances, with: [:survey, :save_survey]

  # GET /balances
  def index
    account = Account.includes(
      people: [
        :award_wallet_accounts,
        :account,
        {
          award_wallet_owners: [
            :person, {
              award_wallet_accounts: [:award_wallet_owner, :person],
            },
          ],
          balances: [:currency, :person],
        },
      ],
    ).find(current_account.id)
    render cell(Balance::Cell::Index, account)
  end

  # GET /people/:person_id/balances/new
  def new
    run Balance::New
    render cell(
      Balance::Cell::New,
      @model,
      currencies: Currency.alphabetical,
      current_account: current_account,
      form: @form,
    )
  end

  # POST /people/:person_id/balances
  def create
    run Balance::Create do
      flash[:success] = 'Created balance!'
      return redirect_to balances_path
    end
    render cell(
      Balance::Cell::New,
      @model,
      currencies: Currency.alphabetical,
      current_account: current_account,
      form: @form,
    )
  end

  # GET /balances/:id
  def edit
    run Balance::Edit
    render cell(
      Balance::Cell::Edit,
      @model,
      currencies: Currency.alphabetical,
      current_account: current_account,
      form: @form,
    )
  end

  # PUT/PATCH /balances/:id
  def update
    run Balance::Update do
      flash[:success] = 'Updated balance!'
      return redirect_to balances_path
    end
    render cell(
      Balance::Cell::Edit,
      @model,
      currencies: Currency.alphabetical,
      current_account: current_account,
      form: @form,
    )
  end

  # DELETE /balances/:id
  def destroy
    run Balance::Destroy do
      flash[:success] = 'Destroyed balance!'
      redirect_to balances_path
    end
  end

  # GET /people/:person_id/balances/survey
  def survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return
    form = Balance::Survey.new(@person)
    form.prepopulate!
    render cell(Balance::Cell::Survey, @person, form: form)
  end

  # POST /people/:person_id/balances/survey
  def save_survey
    @person = load_person
    redirect_if_onboarding_wrong_person_type! && return

    form = Balance::Survey.new(@person)
    if form.validate(survey_params)
      form.save
      redirect_to onboarding_survey_path
    else
      form.repopulate!
      render cell(Balance::Cell::Survey, @person, form: form)
    end
  end

  private

  def load_person
    current_account.people.find(params[:person_id])
  end

  def survey_params
    p = params[:balance_survey].to_unsafe_hash
    {
      balances: (p[:balances_attributes]&.values || []).select do |attrs|
        Types::Form::Bool.(attrs[:present])
      end,
    }
  end
end
