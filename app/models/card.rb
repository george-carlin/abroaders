# A Card is a specific copy of a CardProduct. If 10 people have a Chase
# Sapphire credit card, then there are 10 Cards (one in each person's wallet),
# but only one card *product* (the general concept of a Chase Sapphire card).
class Card < ApplicationRecord
  include Expiration

  # A card has the following timestamps, all of which are nullable:
  #
  # opened_on:
  #   the date the user was approved for the card and their account was opened.
  #   the actual name of the DB column is 'opened_at', opened_on is an alias.
  #
  # earned_at:
  #   the date the user earned their signup bonus. (It might be the same date
  #   they opened the card, if the offer is 'on approval')
  #
  # closed_on:
  #   the date the user's card expired or they closed the card's account.
  #   the actual name of the DB column is 'closed_at', closed_on is an alias.
  #
  # created_at/updated_at
  #   The normal Rails/PSQL timestamp columns. But you already knew that ;)
  #

  alias_attribute :applied_on, :applied_at
  alias_attribute :closed_on, :closed_at
  alias_attribute :opened_on, :opened_at

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

  alias declinable? applyable?

  # Scopes

  scope :recommendations,    -> { where.not(recommended_at: nil) }
  scope :non_recommendation, -> { where(recommended_at: nil) }

  scope :pulled,     -> { where.not(pulled_at: nil) }
  scope :unapplied,  -> { where(applied_at: nil) }
  scope :unclicked,  -> { where(clicked_at: nil) }
  scope :undeclined, -> { where(declined_at: nil) }
  scope :undenied,   -> { where(denied_at: nil) }
  scope :unexpired,  -> { where(expired_at: nil) }
  scope :unopen,     -> { where(opened_at: nil) }
  scope :unpulled,   -> { where(pulled_at: nil) }
  scope :unredenied, -> { where(redenied_at: nil) }
  scope :unseen,     -> { where(seen_at: nil) }

  # compound scopes:

  # Not the best name (any better ideas?), but the opposite of
  # irreversibly_denied. Any recommendation which HASN'T been
  # irreversibly_denied, including recommendations which haven't been denied at
  # all in any sense.
  scope :not_irreversibly_denied, -> do
    recommendations.where(%["denied_at" IS NULL OR "nudged_at" IS NULL]).unredenied
  end

  # Recommendations which still require user action:
  scope :unresolved, -> do
    recommendations.unpulled.unopen.not_irreversibly_denied.unexpired
  end

  # Recommendations which the user can still see:
  scope :visible, -> { recommendations.undeclined.unexpired.unpulled }

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
    Status.new(attributes.slice(*Status::TIMESTAMPS))
  end
end
