class SpendingInfo < ApplicationRecord
  # Attributes

  delegate :couples?, to: :account, prefix: true
  delegate :monthly_spending_usd, to: :account

  BusinessType = Types::Strict::String.enum(
    'no_business',
    'with_ein',
    'without_ein',
  )

  def has_business_with_ein?
    has_business == 'with_ein'
  end

  def has_business_without_ein?
    has_business == 'without_ein'
  end

  def has_business?
    has_business_with_ein? || has_business_without_ein?
  end

  attribute_type :credit_score, CreditScore

  delegate :owner, :owner?, to: :person

  # Associations

  belongs_to :person
  has_one :account, through: :person
end
