# A Card is a specific copy of a CardProduct. If 10 people have a Chase
# Sapphire credit card, then there are 10 Cards (one in each person's wallet),
# but only one card *product* (the general concept of a Chase Sapphire card).
#
# A card has the following timestamps, all of which are nullable:
#
# @!attribute opened_on
#   the date the user was approved for the card and their account was opened.
#
# @!attribute earned_at
#   the date the user earned their signup bonus. (It might be the same date
#   they opened the card, if they signed up through an 'on approval' offer) We
#   don't actually have anything in place yet to update this, so this column is
#   currently null for all cards :/
#
# @!attribute closed_on
#   the date the user's card expired or they closed the card's account.
class Card < ApplicationRecord
  def status
    status_model.name
  end

  def recommendation?
    !recommended_at.nil?
  end

  %w[recommended declined denied open closed].each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  # Validations

  validates :person, presence: true

  validates :decline_reason, presence: true, unless: 'declined_at.nil?'

  validate :product_matches_offer_product

  # Associations

  # All Cards have a CardProduct and, if the user has the card because we
  # recommended it to them, the Card will also be associated with a particular
  # offer.
  #
  # An Offer also belongs_to a Card:roduct, so a Card with an offer is only
  # valid if the offer belongs to the right product. This results in a slightly
  # denormalized DB schema (because product_id will always equal
  # offer.product_id if offer is not nil, so product_id can sometimes contain
  # redundant data), but as far as I can tell this is necessary evil, because
  # all cards have a product, and all offers have a product, but not all cards
  # have an offer.

  belongs_to :product, class_name: 'CardProduct'
  belongs_to :person
  belongs_to :offer

  # Callbacks

  before_validation :set_product_to_offer_product

  # returns true iff the product can be applied for
  def applyable?
    recommendation? && status == "recommended"
  end

  alias declinable?  applyable?
  alias openable?    applyable?
  alias deniable?    applyable?
  alias pendingable? applyable?

  # Scopes

  private

  # TODO move these validations to the operation/contract layer:
  def product_matches_offer_product
    return unless !offer.nil? && !product.nil? && product != offer.product
    errors.add(:product, :doesnt_match_offer)
  end

  def set_product_to_offer_product
    return unless !offer.nil? && !offer.product.nil? && product.nil?
    self.product = offer.product
  end

  def status_model
    Card::Status.build(self)
  end
end
