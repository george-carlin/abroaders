class SoloAccountForm < AccountTypeForm
  include Virtus.model

  attribute :account,              Account
  attribute :monthly_spending_usd, Integer
  attribute :person,               Person
  attribute :eligible,             Boolean

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
    account.update_attributes!(
      monthly_spending_usd: monthly_spending_usd,
      onboarded_type:       true,
    )
    @person = account.owner
    @person.update_attributes!(eligible: eligible?)

    track_intercom_event!
  end

end
