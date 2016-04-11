class SpendingInfo < ActiveRecord::Base

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]
  # Don't use 'no' as a value because it messes up i18n.t
  enum has_business: [ :no_business, :with_ein, :without_ein ]

  alias :has_business_with_ein? :with_ein?
  alias :has_business_without_ein? :without_ein?

  def has_business?
    has_business_with_ein? || has_business_without_ein?
  end

  delegate :main, :main?, to: :person

  # Associations

  belongs_to :person
  has_one :account, through: :person

  # Validations

  MINIMUM_CREDIT_SCORE = 350
  MAXIMUM_CREDIT_SCORE = 850

end
