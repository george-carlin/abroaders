class PhoneNumberForm < ApplicationForm
  attribute :account,      Account
  attribute :phone_number, String

  validates :phone_number, presence: true

  private

  def persist!
    flow = OnboardingFlow.build(account)
    flow.add_phone_number!
    account.update!(
      phone_number:     phone_number,
      onboarding_state: flow.workflow_state,
    )
  end
end
