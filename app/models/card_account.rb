class CardAccount < ApplicationRecord

  # Attributes

  include Statuses

  enum source: {
    from_survey:    0,
    recommendation: 1,
  }

  class << self
    alias_method :recommendations, :recommendation
  end

  # Validations

  validates :person, presence: true
  validates :status, presence: true

  validate :card_matches_offer_card

  # Associations

  # All CardAccounts have a card. When we recommend a card to a user, then the
  # CardAccount will also have an offer, and the card account's card will be
  # equal to the offer's card.
  #
  # To handle this, we're slightly denormalizing the DB schema. The
  # `card_accounts` table has columns `card_id` and `offer_id`. When the card
  # has an offer, `card_id` will be equal to `offer.card_id`, which is set by a
  # callback and reinforced by a validation.
  #
  # Previously we were trying to avoid this 'redundant' data by leaving card_id
  # blank when offer_id was present and getting the card directly from the
  # other, but this created some subtle bugs, mainly that person.cards or
  # account.cards would *only* return cards that were from a card account with
  # no offer. So instead we're now *always* storing card_id even when we
  # technically don't need to.
  #
  # I'm open to suggestions for how we can handle this better.

  belongs_to :card
  belongs_to :person
  belongs_to :offer

  def to_partial_path
    if from_survey?
      # For now these card accounts don't need a custom partial, so use
      # card_account/card_account:
      super
    else
      "card_accounts/#{source}/#{status}_card_account"
    end
  end

  # Callbacks

  before_validation :set_card_to_offer_card

  private

  def card_matches_offer_card
    if offer.present? && card.present? && card != offer.card
      errors.add(:card, :doesnt_match_offer)
    end
  end

  def set_card_to_offer_card
    if offer.present? && offer.card.present? && card.nil?
      self.card = offer.card
    end
  end

end
