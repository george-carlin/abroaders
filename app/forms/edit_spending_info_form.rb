class EditSpendingInfoForm < ApplicationForm
  attribute :monthly_spending_usd, Integer
  attribute :person,                Person
  attribute :monthly_spending_usd,  Integer
  attribute :business_spending_usd, Integer
  attribute :credit_score,          Integer
  attribute :has_business,          String,  default: "no_business"
  attribute :will_apply_for_loan,   Boolean, default: false

  def self.load(person)
    spending_info = person.spending_info
    account       = person.account

    attrs = spending_info.attributes.merge(
      monthly_spending_usd: account.monthly_spending_usd,
      person:               person,
    )
    new(attrs)
  end

  def self.model_name
    SpendingInfo.model_name
  end

  def persisted?
    true
  end

  # Validations

  validates :monthly_spending_usd,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
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
  validates :monthly_spending_usd,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def has_business?
    %w(with_ein without_ein).include?(has_business)
  end

  private

  def persist!
    person.account.update!(monthly_spending_usd: monthly_spending_usd)
    person.spending_info.update!(
      business_spending_usd:  has_business? ? business_spending_usd : nil,
      credit_score:           credit_score,
      has_business:           has_business,
      will_apply_for_loan:    will_apply_for_loan,
    )
  end

end
