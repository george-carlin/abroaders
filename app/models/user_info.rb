class UserInfo < ApplicationRecord

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]
  # Don't use 'no' as a value because it messes up i18n.t
  enum has_business: [ :no_business, :with_ein, :without_ein ]

  def full_name
    [first_name, middle_names, last_name].compact.join(" ")
  end

  alias :has_business_with_ein? :with_ein?
  alias :has_business_without_ein? :without_ein?

  def has_business?
    has_business_with_ein? || has_business_without_ein?
  end

  # Validations

  MINIMUM_CREDIT_SCORE = 350
  MAXIMUM_CREDIT_SCORE = 850

  VALID_TIME_ZONES = ActiveSupport::TimeZone.all.map(&:name)

  validates :user, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true
  validates :time_zone,
    inclusion: { in: VALID_TIME_ZONES },
    presence: true
  validates :credit_score, presence: true,
    numericality: {
      greater_than_or_equal_to: MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    MAXIMUM_CREDIT_SCORE,
      # nil score will be caught by the presence validation; allow nil here to
      # avoid getting a duplicate error message.
      allow_nil: true
    }
  # Spending columns = spending per month, in whole US dollars
  validates :personal_spending,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # nil score will be caught by the presence validation; allow nil here to
      # avoid getting a duplicate error message.
      allow_nil: true
    }
  validates :business_spending,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # nil score will be caught by the presence validation; allow nil here to
      # avoid getting a duplicate error message.
      allow_nil: true
    }

  # Associations

  belongs_to :user

  # Callbacks

  auto_strip_attributes :first_name, :middle_names, :last_name, :phone_number

end
