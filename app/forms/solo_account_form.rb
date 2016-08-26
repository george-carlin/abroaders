class SoloAccountForm < AccountTypeForm
  attribute :account,              Account
  attribute :eligible,             Boolean
  attribute :monthly_spending_usd, Integer
  attribute :person,               Person
  attribute :phone_number,         String

  def self.name
    "SoloAccount"
  end

  def initialize(attributes={})
    assign_attributes(attributes)

    # Set default:
    self.eligible = true if self.eligible.nil?
  end

  def monthly_spending_usd=(new_spending)
    @monthly_spending_usd = new_spending.present? ? new_spending.to_i : nil
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    if: :eligible?

  private

  def persist!
    account.monthly_spending_usd = monthly_spending_usd
    account.onboarded_type       = true
    account.phone_number = phone_number.strip if phone_number.present?
    account.save!
    @person = account.owner
    @person.update_attributes!(eligible: eligible?)

    track_intercom_event!
  end

end
