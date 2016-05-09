class SoloAccountForm < ApplicationForm
  include Virtus.model

  attribute :account,              Account
  attribute :monthly_spending_usd, Integer
  attribute :person,               Person
  attribute :eligible_to_apply,    Boolean

  def self.name
    "SoloAccount"
  end

  def initialize(attributes={})
    assign_attributes(attributes)

    # Set default:
    self.eligible_to_apply = true if self.eligible_to_apply.nil?
  end

  def monthly_spending_usd=(new_spending)
    @monthly_spending_usd = new_spending.present? ? new_spending.to_i : nil
  end

  validates :monthly_spending_usd,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 },
    if: :eligible_to_apply?

  private

  def persist!
    account.update_attributes!(
      monthly_spending_usd: monthly_spending_usd,
      onboarded_type:       true,
    )
    @person = account.people.first
    if eligible_to_apply?
      @person.eligible_to_apply!
    else
      @person.ineligible_to_apply!
    end
  end

end
