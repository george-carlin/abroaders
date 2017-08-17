class PhoneNumbersController < AuthenticatedUserController
  onboard :phone_number, with: [:new, :create, :skip]

  def new
    run PhoneNumber::New
    render cell(PhoneNumber::Cell::New, @model, form: @form)
  end

  def create
    run PhoneNumber::Onboard do
      return redirect_to onboarding_survey_path
    end
    render cell(PhoneNumber::Cell::New, @model, form: @form)
  end

  def skip
    PhoneNumber::Skip.(current_account)
    redirect_to onboarding_survey_path
  end
end
