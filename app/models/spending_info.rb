class SpendingInfo < ApplicationRecord

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]
  # Don't use 'no' as a value because it messes up i18n.t
  enum has_business: [ :with_ein, :without_ein, :no_business ]

  # Validations

  MINIMUM_CREDIT_SCORE = 350
  MAXIMUM_CREDIT_SCORE = 850

  validates :credit_score, presence: true,
    numericality: {
      greater_than_or_equal_to: MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    MAXIMUM_CREDIT_SCORE
    }
  validates :spending_per_month_dollars, presence: true, numericality: true

  # Associations

  belongs_to :user

end
