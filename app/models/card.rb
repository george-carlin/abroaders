# A Card is a specific copy of a CardProduct. If 10 people have a Chase
# Sapphire credit card, then there are 10 Cards (one in each person's wallet),
# but only one card *product* (the general concept of a Chase Sapphire card).
#
# A card has the following timestamps, all of which are nullable:
#
# @!attribute opened_on
#   the date the user was approved for the card and their account was opened.
#
# @!attribute closed_on
#   the date the user's card expired or they closed the card's account.
#
# @!attribute applied_on
#   The date the user *applied* for the card (according to them).
#
# @!attribute declined_at
#   for whatever reason, a user might not want to apply for the card we
#   recommend to them. If that's the case, they have option to 'decline' the
#   card and tell us why. This timestamp tells us when they did so.
#
# @!attribute decline_reason
#   The reason why the user declined the rec. Users can't decline a rec without
#   giving us a reason why.
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
# @!attribute recommended_at
#   the time the admin recommended the product to the user.
#
# @!attribute seen_at
#   the time the user *first* saw this recommendation (by visiting /cards)
#
# @!attribute clicked_at
#   the time the user *first* clicked the 'Find My Card' button. Note that we
#   don't know for sure that they actually applied, just that they clicked
#   the link. (We have to rely on them coming back and saying they applied).
#
# @!attribute expired_at
#   recs which are not clicked within 15 days are assumed to be declined.  For
#   the sake of record-keeping, we note this in a separate time column, rather
#   than reusing 'declined_at' (which would make it unclear whether the user
#   declined the card manually or it was declined automatically).
#
# @!attribute pulled_at
#   pulled means that the admin withdrew the rec after making it.
#
# @!attribute applied_on
#   the date the user *applied* for the card (according to them).
#
# Note that 'expiry' in this sense has nothing to do with the expiry date
# that's printed on a bank card.
#
# NOTE: the distinctions between 'nudging' and 'calling' is an implementation
# detail that should only matter to developers. From the point of view of the
# business and the non-technical stakeholders, both actions are considered to
# be 'calling', and non-developers don't need to know about the terminology
# 'nudge'. We're using this internal distinction because it makes it much
# easier to track a user's actions and figure out where they are in the
# application survey.
#
# All Cards belong to a CardProduct. They also optionally belong to an Offer.
# If the card has an offer, then card.offer.product must equal card.product
# This is enforced in the setters #offer= and #product=; they'll raise an
# error if the product's don't match.
#
# This design isn't ideal because it means there's duplicate data in the DB,
# but I couldn't think of a better alternative.
#
# A subset of cards are *recommendations*. It's a recommendation if it was
# recommended to the user by an admin, as opposed to e.g. the user adding the
# card themselves through the onboarding survey.  Eventually we want to split
# recommendations into their own entirely separate model and DB table. For now,
# a recommendation is any Card that has a 'recommended_at' timestamp.
#
# A recommendation is 'resolved' when either a) the user applies for the
# recommended card (so it's no longer just a recommendation, it's a card
# application and maybe later a card account), or b) something happens which
# means the user no longer can apply for the card. (Right now that means that
# the recommendation either expired, the user declined it, an admin pulled it,
# or the recommended offer is no longer available.)
#
# A recommendation is 'actionable' when it's either unresolved, or the user
# applied for it and the results of that application are still not final. So an
# 'actionable card' is basically the set of cards that are either 1) unresolved
# recommendations or 2) unresolved applications.
class Card < ApplicationRecord
  def status
    status_model.name
  end

  def recommended?
    !recommended_at.nil?
  end

  %w[declined denied open closed].each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  def applied?
    !applied_on.nil?
  end

  def expired?
    !expired_at.nil?
  end

  def opened?
    !opened_on.nil?
  end

  def nudged?
    !nudged_at.nil?
  end

  def pulled?
    !pulled_at.nil?
  end

  def redenied?
    !redenied_at.nil?
  end

  # Validations

  validates :person, presence: true

  validates :decline_reason, presence: true, unless: 'declined_at.nil?'

  # Associations

  belongs_to :product, class_name: 'CardProduct'
  belongs_to :person
  has_one :account, through: :person
  belongs_to :offer

  alias_attribute :card_product, :product

  # Callbacks

  before_save :set_product_to_offer_product

  # returns true iff the product can be applied for
  def applyable?
    recommended? && status == 'recommended'
  end

  alias declinable?  applyable?
  alias openable?    applyable?
  alias deniable?    applyable?
  alias pendingable? applyable?

  # Scopes

  scope :recommended, -> { where.not(recommended_at: nil) } do
    # recs which still require user action:
    def actionable
      unpulled.unopen.where(%["denied_at" IS NULL OR "nudged_at" IS NULL]).unredenied.unexpired.undeclined
    end
  end

  scope :accounts, -> { where.not(opened_on: nil) }

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

  private

  def set_product_to_offer_product
    return unless !offer.nil? && !offer.product.nil? && product.nil?
    self.product = offer.product
  end

  def status_model
    Card::Status.build(self)
  end
end
