class CardAccount < ApplicationRecord

  # Attributes

  # 'declined' means the user would not, or could not, apply for the card
  #            which we recommended to them.
  # 'denied' means that the user applied for the card, but the application
  #          was denied by the bank.
  #
  # Note that the numeric keys of the statuses don't necessarily match
  # the order in which a card account flows through the statuses, because
  # some statuses were added later in the app's development than others.
  enum status: {
    unknown:     0,
    recommended: 1,
    declined:    2,
    clicked:     3,
    pending:     7,
    denied:      4,
    open:        5,
    closed:      6,
    applied:     9,
  }

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


  # Callbacks

  before_validation :set_card_to_offer_card

  def decline_with_reason!(reason)
    update_attributes!(
      declined_at: Time.now, status: :declined, decline_reason: reason
    )
  end

  def applyable?
    status == "recommended"
  end

  def declinable?
    status == "recommended"
  end

  def deniable?
    status == "recommended"
  end

  def openable?
    status == "recommended"
  end
  alias_method :acceptable?, :openable?

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
