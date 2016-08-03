class Person < ApplicationRecord
  include ReadyToApply

  # Attributes

  alias_attribute :owner, :main

  def companion?
    !main?
  end

  def type
    owner ? "owner" : "companion"
  end

  delegate :credit_score, :will_apply_for_loan,
    :business_spending_usd, :has_business, :has_business?, :has_business_with_ein?,
    :has_business_without_ein?, :no_business?,
    to: :spending_info, allow_nil: true

  def onboarded_spending?
    !!spending_info&.persisted?
  end

  def onboarded?
    onboarded_eligibility? && onboarded_balances? && (
      (ineligible?) || (
        onboarded_cards? && onboarded_spending? && readiness_given?
      )
    )
  end

  def can_receive_recommendations?
    onboarded? && eligible? && ready_to_apply?
  end

  def status
    if self.ineligible?
      "Ineligible"
    elsif self.ready
      "Ready"
    else
      "Eligible(NotReady)"
    end
  end

  concerning :Eligibility do
    def onboarded_eligibility?
      !eligible.nil?
    end

    def ineligible
      !eligible
    end
    alias_method :ineligible?, :ineligible
  end

  # Validations

  NAME_MAX_LENGTH  = 50

  validates :account, uniqueness: { scope: :main }

  # Associations

  belongs_to :account
  has_one :spending_info, dependent: :destroy
  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations }, class_name: "CardAccount"
  has_many :cards, through: :card_accounts

  has_many :balances
  has_many :currencies, through: :balances

  # Callbacks

  auto_strip_attributes :first_name

  # Scopes

  scope :main,      -> { where(main: true) }
  scope :companion, -> { where(main: false) }

end
