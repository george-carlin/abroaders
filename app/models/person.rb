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

  def has_partner?
    warn 'Person#has_partner? is deprecated, use #partner? instead'
    partner?
  end

  def phone_number
    account.phone_number&.number
  end

  def signed_up_at
    account.created_at
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

  has_many :pulled_card_recommendations, -> { recommended.pulled }, class_name: 'Card'
  has_many :unpulled_cards, -> { unpulled }, class_name: 'Card'
  has_many :actionable_card_recommendations, -> { recommended.actionable }, class_name: 'Card'
  has_many :unresolved_card_recommendations, -> { recommended.unresolved }, class_name: 'Card'

  delegate :recommendation_note, :recommendation_notes, to: :account

  def actionable_card_recommendations?
    actionable_card_recommendations.any?
  end

  def unresolved_recommendation_request?
    !unresolved_recommendation_request.nil?
  end

  def unresolved_card_recommendations?
    unresolved_card_recommendations.any?
  end

  has_many :balances
  has_many :currencies, through: :balances

  has_many :award_wallet_owners
  has_many :award_wallet_accounts, through: :award_wallet_owners

  has_many :recommendation_requests
  has_many :confirmed_recommendation_requests,
           -> { confirmed },
           class_name: 'RecommendationRequest'
  # They should only ever have ONE unresolved request. If they have more than
  # one, something's gone wrong somewhere
  has_one :unresolved_recommendation_request,
          -> { unresolved },
          class_name: 'RecommendationRequest'

  # Callbacks

  # Scopes

  scope :companion, -> { where(owner: false) }
  scope :eligible,  -> { where(eligible: true) }
  scope :owner,     -> { where(owner: true) }
end
