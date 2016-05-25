class CardAccount < ApplicationRecord

  def status
    status_model.name
  end

  def from_survey?
    recommended_at.nil?
  end

  def recommendation?
    !from_survey?
  end

  %w[recommended declined denied open closed].each do |status|
    define_method "#{status}?" do
      status == status
    end
  end

  # Validations

  validates :person, presence: true

  validates :decline_reason, presence: true, if: "declined_at.present?"

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

  # returns true iff the card can be applied for
  def applyable?
    recommendation? && status == "recommended"
  end

  alias_method :declinable?, :applyable?
  alias_method :openable?, :applyable?
  alias_method :deniable?, :applyable?
  alias_method :pendingable?, :applyable?

  def show_survey?
    status_model.show_survey?
  end

  # Scopes

  scope :from_survey,     -> { where(recommended_at: nil) }
  scope :recommendations, -> { where.not(recommended_at: nil) }

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

  def status_model
    Status.new(attributes.slice(*Status::TIMESTAMPS))
  end
end
