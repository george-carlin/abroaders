class Person < ApplicationRecord
  delegate :email, to: :account

  def companion?
    !owner
  end

  def partner
    owner? ? account.companion : account.owner
  end

  delegate :first_name, to: :partner, prefix: true

  def partner?
    !partner.nil?
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
  has_many :card_recommendations, -> { recommended }, class_name: 'Card'
  has_many :card_products, through: :cards
  has_many :home_airports, through: :account
  has_many :recommendation_notes, through: :account
  has_many :regions_of_interest, through: :account
  has_many :travel_plans, through: :account

  has_many :unpulled_cards, -> { unpulled }, class_name: 'Card'
  has_many :actionable_card_recommendations, -> { recommended.actionable }, class_name: 'Card'

  has_many :balances
  has_many :currencies, through: :balances

  has_many :award_wallet_owners
  has_many :award_wallet_accounts, through: :award_wallet_owners

  # Callbacks

  # Scopes

  scope :companion, -> { where(owner: false) }
  scope :eligible,  -> { where(eligible: true) }
  scope :owner,     -> { where(owner: true) }
end
