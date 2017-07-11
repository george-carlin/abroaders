require 'types'

# A sign-up offer that banks etc. use to entice people to sign up for a
# particular card product. For example, "spend $1000 on this card in your first
# 3 months and receive 50,000 free points with Airline X".
#
# There are different ways you can get the bonus, as noted in the 'Condition'
# type (see inline comments).
#
# Whether or not the other attributes will be present depends on the condition:
#
# 'spend' = the minimum that the person has to spend using the card
#           to get the bonus (not relevant for 'on approval' cards)
# 'days'  = how long the user has after opening the card account to spend enough
#           money to earn the bonus. (Only relevant for 'on_minimum_spend' cards)
#
# 'cost' is the card's annual fee for the first year. The 'normal' annual fee
# is reflected in the 'annual_fee' attribute of the CardProduct, but typically
# the annual fee will be waived in the first year, so the offer reflects this.
#
# 'link' is the link to the page where people can sign up for the cards.  NOTE:
# any links from our app to the card application page MUST be nofollowed, for
# compliance reasons.
class Offer < ApplicationRecord
  # Which of our affiliate partners provides this offer, if any?
  Partner = Types::Strict::String.enum(
    'award_wallet',
    'card_benefit',
    'card_ratings',
    'credit_cards',
    'none',
  )

  attribute_type :condition, Condition
  attribute_type :partner, Partner

  # Associations

  belongs_to :card_product
  has_many :cards
  has_many :recommendations, -> { recommended }, class_name: 'Card'
  has_many :unresolved_recommendations, -> { recommended.unresolved }, class_name: 'Card'
  has_one :currency, through: :card_product

  delegate :bank, to: :card_product
  delegate :name, to: :bank, prefix: true
  delegate :name, to: :card_product, prefix: true
  delegate :name, to: :currency, prefix: true

  # Callbacks

  before_save :nullify_irrelevant_columns

  # Methods

  def live?
    killed_at.nil?
  end

  def dead?
    !killed_at.nil?
  end

  def value
    value_cents / 100.0 unless value_cents.nil?
  end

  def value=(value_dollars)
    self.value_cents = (value_dollars.to_f * 100).round
  end

  # Scopes

  scope :live, -> { where(killed_at: nil) }
  scope :dead, -> { where.not(killed_at: nil) }

  # Right now the the only condition that an Offer must satisfy to be
  # recommendable is that it's live, but you never know if that  may change in
  # future, so use a more precise scope name to be more future-proof.
  def self.recommendable
    live
  end

  private

  def nullify_irrelevant_columns
    self.days = nil unless Condition.days?(condition)
    self.spend = nil unless Condition.spend?(condition)
    self.points_awarded = nil unless Condition.points_awarded?(condition)
  end
end
