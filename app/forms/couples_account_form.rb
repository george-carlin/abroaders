class CouplesAccountForm < AccountTypeForm
  attribute :account,              Account
  attribute :person_0,             Person
  attribute :person_1,             Person
  attribute :monthly_spending_usd, Integer
  attribute :companion_first_name, String
  attribute :eligibility,          String, default: "both"
  attribute :phone_number,         String

  def self.name
    "CouplesAccount"
  end

  ELIGIBILITY = %w[both person_0 person_1 neither]

  def person_0_eligible?
    %w[both person_0].include?(eligibility)
  end

  def person_1_eligible?
    %w[both person_1].include?(eligibility)
  end

  def neither_eligible?
    eligibility == "neither"
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    unless: :neither_eligible?

  validates :companion_first_name, presence: true

  private

  def persist!
    account.monthly_spending_usd = monthly_spending_usd
    account.onboarding_survey.choose_account_type!
    account.phone_number = phone_number.strip if phone_number.present?
    account.save!
    self.person_0 = account.people.first
    self.person_0.update_attributes!(eligible: person_0_eligible?)
    self.person_1 = account.create_companion!(
      eligible:   person_1_eligible?,
      first_name: companion_first_name,
    )
  end
end
