class Person < ApplicationRecord
  include EligibleToApply
  include ReadyToApply

  # Attributes

  alias_attribute :main_passenger?, :main

  def companion?
    !main?
  end

  delegate :credit_score, :will_apply_for_loan,
    :business_spending_usd, :has_business, :has_business?, :has_business_with_ein?,
    :has_business_without_ein?, :no_business?,
    to: :spending_info, allow_nil: true

  def onboarded_spending?
    !!spending_info&.persisted?
  end

  def onboarded?
    onboarded_spending? && onboarded_cards? && onboarded_balances? &&
      ready_to_apply?
  end

  def recommend_offer!(offer)
    card_recommendations.recommended.create!(
      offer:          offer,
      recommended_at: Time.now,
    )
  end

  # Validations

  NAME_MAX_LENGTH  = 50

  validates :account, uniqueness: { scope: :main }

  # Associations

  belongs_to :account
  has_one :spending_info, dependent: :destroy
  has_many :card_accounts
  has_many :card_recommendations, -> { recommendation }, class_name: "CardAccount"
  has_many :cards, through: :card_accounts

  has_many :balances
  has_many :currencies, through: :balances

  # Callbacks

  auto_strip_attributes :first_name

  # Scopes

  scope :main,      -> { where(main: true) }
  scope :companion, -> { where(main: false) }

end
