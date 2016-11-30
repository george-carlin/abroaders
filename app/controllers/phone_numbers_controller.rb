class PhoneNumbersController < AuthenticatedUserController
  onboard :phone_number, with: [:new, :create, :skip]

  def new
    form PhoneNumber::Create
  end

  def create
    run PhoneNumber::Create do
      return redirect_to onboarding_survey_path
    end
    render :new
  end

  def skip
    Account::Onboarder.new(current_account).skip_phone_number!
    redirect_to onboarding_survey_path
  end
end
