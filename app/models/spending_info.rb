class SpendingInfo < ActiveRecord::Base

  # Attributes

  # Don't use 'no' as a value because it messes up i18n.t
  enum has_business: [ :no_business, :with_ein, :without_ein ]

  alias :has_business_with_ein? :with_ein?
  alias :has_business_without_ein? :without_ein?

  def has_business?
    has_business_with_ein? || has_business_without_ein?
  end

  # Associations

  belongs_to :passenger

  # Validations

  MINIMUM_CREDIT_SCORE = 350
  MAXIMUM_CREDIT_SCORE = 850

  validates :credit_score, presence: true,
    numericality: {
      greater_than_or_equal_to: MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    MAXIMUM_CREDIT_SCORE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  # Spending columns = spending per month, in whole US dollars
  validates :personal_spending,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  validates :business_spending,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }

end
