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
# If the card has an offer, then card.offer.card_product must equal
# card.card_product This is enforced in the setters #offer= and #card_product=;
# they'll raise an error if the product's don't match.
#
# This design isn't ideal because it means there's duplicate data in the DB,
# but I couldn't think of a better alternative.
class Card < ApplicationRecord
  def recommended?
    !recommended_at.nil?
  end

  def closed?
    !closed_on.nil?
  end

  def opened?
    !opened_on.nil?
  end

  def unclosed?
    !closed?
  end

  def unopened?
    !opened?
  end

  include CardRecommendation::Predicates

  # Validations

  # Associations

  belongs_to :card_product
  belongs_to :offer
  belongs_to :person
  belongs_to :recommended_by, class_name: 'Admin'
  has_one :account, through: :person
  has_one :currency, through: :card_product

  delegate :bank, to: :card_product, allow_nil: true
  delegate :name, to: :bank, prefix: true

  # In reality there should always be a currency present, but if we
  # don't set allow_nil to true it's too much of a PITA to test.
  delegate :name, to: :currency, prefix: true, allow_nil: true

  # Callbacks

  before_save :set_product_to_offer_product

  # Scopes

  # A subset of Cards are *recommendations*. These are cards that were
  # recommended to the user by an admin, as opposed to e.g. the user adding it
  # themselves through the onboarding survey.  Eventually we want to split
  # recommendations into their own entirely separate model and DB table. For now,
  # a recommendation is any Card that has a 'recommended_at' timestamp.
  scope :recommended, -> { where.not(recommended_at: nil) } do
    # A recommendation is 'actionable' when it's either unresolved (see below),
    # or the user applied for it and the results of that application are still
    # not final. So an 'actionable card' is basically the set of cards that are
    # either 1) unresolved recommendations or 2) unresolved applications.
    def actionable
      unopened.where(%["denied_at" IS NULL OR "nudged_at" IS NULL]).unredenied.unexpired.undeclined
    end

    # A recommendation is 'resolved' when either a) the user applies for the
    # recommended card (so it's no longer just a recommendation, it's a card
    # application and maybe later a card account), or b) something happens
    # which means the user no longer can apply for the card. (Right now that
    # means that the recommendation either expired, the user declined it, or
    # the recommended offer is no longer available.
    #
    # However, we don't have anything smart in place to handle the case where
    # the recommended offer is no longer available; for now admins have to
    # delete the rec entirely when this happens - so this scope doesn't exclude
    # them in that case.)
    def unresolved
      unapplied.unexpired.undeclined
    end
  end

  scope :accounts, -> { where.not(opened_on: nil) }

  scope :unapplied,  -> { where(applied_on: nil) }
  scope :unclicked,  -> { where(clicked_at: nil) }
  scope :unclosed,   -> { where(closed_on: nil) }
  scope :undeclined, -> { where(declined_at: nil) }
  scope :undenied,   -> { where(denied_at: nil) }
  scope :unexpired,  -> { where(expired_at: nil) }
  scope :unopened,   -> { where(opened_on: nil) }
  scope :unredenied, -> { where(redenied_at: nil) }
  scope :unseen,     -> { where(seen_at: nil) }

  # compound scopes:

  private

  def set_product_to_offer_product
    return unless !offer.nil? && !offer.card_product.nil? && card_product.nil?
    self.card_product = offer.card_product
  end
end
