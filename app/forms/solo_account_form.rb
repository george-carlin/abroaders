class SoloAccountForm < Form
  attr_accessor :account
  attr_reader :monthly_spending_usd, :person
  attr_boolean_accessor :eligible_to_apply

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

  def save
    super do
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

end
