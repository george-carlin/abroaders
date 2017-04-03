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
#
# @!attribute applied_on
#   The date the user *applied* for the card (according to them).
#
# @!attribute denied_at
#   If the user applied for the card but their application was denied, this
#   timestamp tells us when. Note that we use the word 'denied' to mean that a
#   user applied for a card but was denied by the bank, while 'declined' means
#   that we recommended a card to a user but they told us they wouldn't apply
#   for it.
#
# @!attribute redenied_at
#   If the user is denied, calls, and gets denied again, 'redenied_at' is the
#   date they were denied for the second time. We need this column for two
#   reasons: 1) it's the only way to distinguish between a user who has called
#   for reconsideration, and a user who has been denied again after calling for
#   reconsideration - and 2) we need to preserve the original denied_at
#   timestamp because that's what determines when the user can apply again.
#
# @!attribute nudged_at
#   If the user applies for the card but doesn't hear back immediately, we
#   encourage them to call the bank to speed up the application process. If
#   they tell us they've called, then 'nudged_at' is the time they told us they
#   called. Note that nudged_at is distinct from 'called_at', explained below.
#
# @!attribute called_at
#   If the user applies and is *denied* (as opposed to just not having heard
#   back yet), we also encourage them to call and see if the application can be
#   reconsidered. In this case we set the called_at timestamp, not the
#   nudged_at timestamp.
#
#   So in brief: a 'nudge' is when they call the bank about a *pending*
#   application. A 'call' is when they call the bank about a *denied*
#   application. (If they nudge and then are denied, we don't encourage them to
#   call again. They should only call if the application was denied without
#   nudging. So nudged_at and called_at will never both be present)
#
# NOTE: the distinctions between 'nudging' and 'calling' is an implementation
# detail that should only matter to developers. From the point of view of the
# business and the non-technical stakeholders, both actions are considered to
# be 'calling', and non-developers don't need to know about the terminology
# 'nudge'. We're using this internal distinction because it makes it much
# easier to track a user's actions and figure out where they are in the
# application survey.
class Card < ApplicationRecord
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

  alias declinable?  applyable?
  alias openable?    applyable?
  alias deniable?    applyable?
  alias pendingable? applyable?

  # Scopes

  scope :recommendations, -> { where.not(recommended_at: nil) }

  scope :pulled,     -> { where.not(pulled_at: nil) }
  scope :unapplied,  -> { where(applied_on: nil) }
  scope :unclicked,  -> { where(clicked_at: nil) }
  scope :undeclined, -> { where(declined_at: nil) }
  scope :undenied,   -> { where(denied_at: nil) }
  scope :unexpired,  -> { where(expired_at: nil) }
  scope :unopen,     -> { where(opened_on: nil) }
  scope :unpulled,   -> { where(pulled_at: nil) }
  scope :unredenied, -> { where(redenied_at: nil) }
  scope :unseen,     -> { where(seen_at: nil) }

  # compound scopes:

  # Recommendations which still require user action:
  scope :unresolved, -> { recommendations.unpulled.unopen.where(%["denied_at" IS NULL OR "nudged_at" IS NULL]).unredenied.unexpired.undeclined }

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
