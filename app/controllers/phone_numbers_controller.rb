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
    flow = OnboardingFlow.build(current_account)
    flow.skip_phone_number!
    current_account.update!(onboarding_state: flow.workflow_state)
    redirect_to onboarding_survey_path
  end

end
