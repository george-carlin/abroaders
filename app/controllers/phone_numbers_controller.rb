class PhoneNumbersController < AuthenticatedUserController
  onboard :phone_number, with: [:new, :create, :skip]

  def new
    form PhoneNumber::Create
  end

  def create
    run PhoneNumber::Create do
      # TODO move this inside the operation, and wrap in a transaction
      AccountOnboarder.new(current_account).add_phone_number!
      return redirect_to onboarding_survey_path
    end
    render :new
  end

  def skip
    AccountOnboarder.new(current_account).skip_phone_number!
    redirect_to onboarding_survey_path
  end
end
