class AccountsController < AuthenticatedUserController
  onboard :account_type, with: [:type, :submit_type]

  def edit
    run Registration::Edit
    render cell(Registration::Cell::Edit, @model, form: @form)
  end

  def update
    run Registration::Update do
      flash[:success] = 'Saved settings!'
      # If they changed their password then they'll have been signed out:
      sign_in :account, @model, bypass: true
    end
    render cell(Registration::Cell::Edit, @model, form: @form)
  end

  # 'dashboard' lives under ApplicationController. This is because there are
  # two dashboards, the regular dashboard and the admin dashboard, but we can't
  # split it into two actions because they both live under the same path
  # (root_path)

  def type
    run Account::Type
    render cell(Onboarding::Cell::Account::Type, nil, destination: result['model'])
  end

  def submit_type
    run Account::Type::Onboard
    redirect_to onboarding_survey_path
  end
end
