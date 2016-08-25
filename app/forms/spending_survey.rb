class SpendingSurvey < ApplicationForm
  attribute :person,                Person
  attribute :business_spending_usd, Integer
  attribute :credit_score,          Integer
  attribute :has_business,          String,  default: "no_business"
  attribute :will_apply_for_loan,   Boolean, default: false

  # Make form_for play nicely:
  def self.name
    "SpendingInfo"
  end

  def has_business?
    %w[with_ein without_ein].include?(has_business)
  end

  # Validations

  validates :credit_score,
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: ::SpendingInfo::MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    ::SpendingInfo::MAXIMUM_CREDIT_SCORE,
    },
    presence: true

  validates :business_spending_usd,
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
    },
    presence: true,
    if: :has_business?

  private

  def persist!
    person.create_spending_info!(
      business_spending_usd: has_business? ? business_spending_usd : nil,
      credit_score:          credit_score,
      has_business:          has_business,
      will_apply_for_loan:   will_apply_for_loan,
    )
  end

end
