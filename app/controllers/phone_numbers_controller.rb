class PhoneNumbersController < AuthenticatedUserController
  onboard :phone_number, with: [:new, :create, :skip]

  def new
    @form = PhoneNumberForm.new(account: current_account)
  end

  def create
    @form = PhoneNumberForm.new(account: current_account)
    @form.update!(params[:account])
    redirect_to onboarding_survey_path
  end

  def skip
    AccountOnboarder.new(current_account).skip_phone_number!
    redirect_to onboarding_survey_path
  end
end
