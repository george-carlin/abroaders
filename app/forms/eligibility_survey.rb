class EligibilitySurvey < ApplicationForm
  attribute :account,  Account
  attribute :eligible, String

  ELIGIBILITY = %w[both owner companion neither].freeze

  validates :eligible, inclusion: { in: ELIGIBILITY }

  private

  def persist!
    case eligible
    when "both"
      account.owner.update_attributes!(eligible: true)
      account.companion.update_attributes!(eligible: true)
    when "owner"
      account.owner.update_attributes!(eligible: true)
    when "companion"
      account.companion.update_attributes!(eligible: true)
    when "neither" # noop
    end
    Account::Onboarder.new(account).add_eligibility!
  end
end
