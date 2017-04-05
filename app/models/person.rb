class Person < ApplicationRecord
  delegate :email, to: :account

  def can_receive_recommendations?
    onboarded? && eligible? && ready?
  end

  def companion?
    !owner
  end

  def has_recent_recommendation?
    return false if last_recommendations_at.nil?
    last_recommendations_at >= Time.current - 30.days
  end

  def phone_number
    account.phone_number&.number
  end

  def signed_up_at
    account.created_at
  end

  def status
    if self.ineligible?
      "Ineligible"
    elsif self.ready?
      "Ready"
    else
      "Eligible(NotReady)"
    end
  end

  def type
    owner ? 'owner' : 'companion'
  end

  concerning :Eligibility do
    def ineligible
      !eligible
    end
    alias_method :ineligible?, :ineligible
  end

  concerning :Readiness do
    def unready
      !ready?
    end
    alias_method :unready?, :unready
  end

  # Validations

  NAME_MAX_LENGTH = 50

  validates :account, uniqueness: { scope: :owner }

  # Associations

  belongs_to :account
  has_one :spending_info, dependent: :destroy
  has_many :cards
  has_many :card_accounts, -> { where.not(opened_on: nil) }, class_name: 'Card'
  has_many :card_recommendations, -> { recommendations }, class_name: 'Card'
  has_many :card_products, through: :cards

  has_many :pulled_card_recommendations, -> { recommendations.pulled }, class_name: 'Card'
  has_many :unpulled_cards, -> { unpulled }, class_name: 'Card'

  has_many :balances
  has_many :currencies, through: :balances

  has_many :award_wallet_owners
  has_many :award_wallet_accounts, through: :award_wallet_owners

  # Callbacks

  # Scopes

  scope :owner,     -> { where(owner: true) }
  scope :companion, -> { where(owner: false) }
end
