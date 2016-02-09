class CardAccount < ApplicationRecord

  # Attributes

  include Statuses

  delegate :brand, :type, :bp, :name, :identifier, :bank_name, :currency,
    :currency_name,
    to: :card,
    prefix: true

  # Validations

  # Exactly one of card_id and offer_id should be present - because if
  # we know the offer, we can get the card through the offer instead of 
  # saving the card directly.
  #
  # In practice, all card accounts created through the recommendation system
  # will have an offer; the only times we *won't* know the offer are:
  #
  # a) when the user tells about his pre-existing card accounts on signup.
  # b) for the legacy data we had when the app was first created.

  validates :user, presence: true
  validates :status, presence: true

  validate :exactly_one_of_card_and_offer_is_present

  # Associations

  belongs_to :card
  belongs_to :user
  belongs_to :offer, class_name: "CardOffer"

  alias_method :original_card, :card
  def card
    offer.present? ? offer.card : original_card
  end

  private

  def exactly_one_of_card_and_offer_is_present
    if original_card.present? && offer.present?
      errors.add(:card, :present)
    elsif original_card.nil? && offer.nil?
      errors.add(:card, :blank)
    end
  end

end
