class CardAccount < ApplicationRecord

  # Attributes

  include Statuses

  delegate :brand, :type, :bp, :name, :identifier, :bank_name, to: :card,
    prefix: true

  # Validations

  validates :card, presence: true
  validates :user, presence: true
  validates :status, presence: true

  validate :offer_belongs_to_card

  # Associations

  belongs_to :card
  belongs_to :user
  belongs_to :offer, class_name: "CardOffer"

  private

  def offer_belongs_to_card
    if offer.present? && card.present? && offer.card != card
      errors.add(:offer, "must belong to the card")
    end
  end

end
