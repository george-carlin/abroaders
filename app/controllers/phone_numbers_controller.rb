class PhoneNumbersController < AuthenticatedUserController
  onboard :phone_number, with: [:new, :create, :skip]

  def new
    @form = PhoneNumberForm.new(account: current_account)
  end

  def create
    @form = PhoneNumberForm.new(account: current_account)
    if @form.update(phone_number_params)
      redirect_to onboarding_survey_path
    else
      render :new
    end
  end

  def skip
    AccountOnboarder.new(current_account).skip_phone_number!
    redirect_to onboarding_survey_path
  end

  private

  def phone_number_params
    params.require(:account).permit(:phone_number)
  end
end
