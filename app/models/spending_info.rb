class SpendingInfo < ApplicationRecord
  MINIMUM_CREDIT_SCORE = 350
  MAXIMUM_CREDIT_SCORE = 850

  CreditScore = Types::Strict::Int.constrained(
    gteq: MINIMUM_CREDIT_SCORE,
    lteq: MAXIMUM_CREDIT_SCORE,
  )

  # Attributes

  delegate :couples?, to: :account, prefix: true
  delegate :monthly_spending_usd, to: :account

  def unready
    !ready?
  end
  alias unready? unready

  # TODO double check this won't fuck up the data
  BusinessType = Types::Strict::String.enum(
    'no_business',
    'with_ein',
    'without_ein',
  )
  enum has_business: BusinessType.options[:values]

  alias has_business_with_ein? with_ein?
  alias has_business_without_ein? without_ein?

  def has_business?
    has_business_with_ein? || has_business_without_ein?
  end

  # Since validations don't live in the model class, there's no reason to let
  # a SpendingInfo ever be initialized with an invalid CreditScore:
  def credit_score=(new_credit_score)
    super(CreditScore.(new_credit_score))
  end

  delegate :owner, :owner?, to: :person

  # Associations

  belongs_to :person
  has_one :account, through: :person
end
