require 'types'

# A sign-up offer that banks etc. use to entice people to sign up for a
# particular card product. For example, "spend $1000 on this card in your first
# 3 months and receive 50,000 free points with Airline X".
#
# There are different ways you can get the bonus, as noted in the 'condition'
# attribute:
#
# on_approval:       points awarded as soon as approved for card
# on_first_purchase: points awarded once you make 1st purchase with card
# on_minimum_spend:  points awarded if you spend $X within Y days
#
# It's also possible that a user will tell us that they have a particular card
# but doesn't tell us which offer they used to sign up with, in which case
# the condition will be 'unknown'. If it's a card that we recommended to them,
# however, we will always know the condition.
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
#
class Offer < ApplicationRecord
  # Attributes

  # What does the customer have to do to receive the points?
  Conditions = Types::Strict::String.enum(
    'on_approval',       # points awarded as soon as approved for card
    'on_first_purchase', # points awarded once you make 1st purchase with card
    'on_minimum_spend',  # points awarded if you spend $X within Y days
    'unknown', # we don't know what offer the person signed up with
  ).freeze

  # fail noisily when trying to set an invalid condition
  def condition=(new_condition)
    super(Conditions.(new_condition))
  end

  # Which of our affilite partners is this offer for?
  Partners = Types::Strict::String.enum(
    'award_wallet',
    'card_benefit',
    'card_ratings',
    'credit_cards',
    'none',
  )

  # fail noisily when trying to set an invalid partner
  def partner=(new_partner)
    super(Partners.(new_partner))
  end

  # Associations

  belongs_to :product, class_name: 'CardProduct'
  has_many :cards

  # Callbacks

  before_save :nullify_irrelevant_columns

  # Methods

  def live?
    killed_at.nil?
  end

  def dead?
    !killed_at.nil?
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
    self.days  = nil if condition == 'on_approval'
    self.spend = nil unless condition == 'on_minimum_spend'
  end
end
