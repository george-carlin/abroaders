# A Card is a specific copy of a CardProduct. If 10 people have a Chase
# Sapphire credit card, then there are 10 Cards (one in each person's wallet),
# but only one card *product* (the general concept of a Chase Sapphire card).
class Card < ApplicationRecord
  include Expiration

  # A card has the following timestamps, all of which are nullable:
  #
  # recommended_at:
  #   the date the admin recommended the product to the user. May be null,
  #   if the user added the product in the onboarding survey, or if the admin
  #   assigned the card to the user 'manually' (not through the recommendation
  #   system), e.g. to handle legacy data.
  #
  # clicked_at:
  #   the date the user clicked the 'apply' button on the card recommendation
  #   page. Note that we don't know for sure that they actually applied, just
  #   that they clicked the link. (We have to rely on them coming back and
  #   telling us that they applied).
  #
  # declined_at:
  #   For whatever reason, a user might not want to apply for the card we
  #   recommend to them. If that's the case, they have option to 'decline' the
  #   card and tell us why. This timestamp tells us when they declined.
  #   (There's also a 'decline_reason' text field for them to say why they're
  #   declining.)
  #
  # applied_at:
  #   the date the user *applied* for the card (according to them).
  #
  # opened_at:
  #   the date the user was approved for the card and their account was opened.
  #
  # earned_at:
  #   the date the user earned their signup bonus. (It might be the same date
  #   they opened the card, if the offer is 'on approval')
  #
  # closed_at:
  #   the date the user's card expired or they closed the card's account.
  #
  # denied_at:
  #   If the user applied for the card but their application was denied,
  #   this timestamp tells us when.
  #
  # nudged_at:
  #   If the user applies for the card but doesn't hear back immediately,
  #   we encourage them to call the bank to speed up the application process.
  #   If they tell us they've called, then 'nudged_at' is the date they called.
  #   Note that nudged_at is distinct from 'called_at', explained below:
  #
  # called_at
  #   If the user applies and is *denied* (as opposed to just not having
  #   heard back yet), we also encourage them to call and see if the application
  #   can be reconsidered. In this case we set the called_at timestamp, not the
  #   nudged_at timestamp.
  #
  #   So in brief: a 'nudge' is when they call the bank about a *pending*
  #   application. A 'call' is when they call the bank about a *denied*
  #   application. (If they nudge and then are denied, we don't encourage them
  #   to call again. They should only call if the application was denied
  #   without nudging. So nudged_at and called_at will never both be present)
  #
  #   NOTE: the distinction between 'nudging' and 'calling' is a code-level
  #   thing that should only matter to developers. From the point of view of
  #   the business and the non-technical stakeholders, both actions are
  #   considered to be 'calling', and non-developers don't need to know about
  #   the terminology 'nudge'. We're using this internal distinction because it
  #   makes it much easier to track a user's actions and figure out where they
  #   are in the application survey.
  #
  # redenied_at
  #   If the user is denied, calls, and gets denied again, this is the date
  #   they were denied for the second time. We need this column for two
  #   reasons: 1) it's the only way to distinguish between a user who has
  #   called for reconsideration, and a user who has been denied again after
  #   calling for reconsideration - and 2) we need to preserve the original
  #   denied_at timestamp because that's what determines when the user can
  #   apply again
  #
  # expired_at
  #   Cards which are recommended but not clicked within 15 days are assumed to
  #   be declined. But for the sake of record-keeping, we mark this with a
  #   separate time column, rather than reusing 'declined_at' (in which case it
  #   would be unclear whether the user declined the card manually or it was
  #   declined automatically). Note that 'expiry' in this sense has nothing to
  #   do with the expiry date that's printed on a bank card.
  #
  # created_at/updated_at
  #   The normal Rails/PSQL timestamp columns. But you already knew that ;)
  #

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

  def show_survey?
    status_model.show_survey?
  end

  # Scopes

  # There are currently two ways that a card can be added to a user's Abroaders
  # account: they can add it on the onboarding survey, or it can be recommended
  # to them by an admin. We know which source the Card came from because
  # recommended_at will be nil in the former case and present in the latter.

  scope :recommendations, -> { where.not(recommended_at: nil) }
  scope :from_survey,     -> { where(recommended_at: nil) }

  # basic 'timestamp present' scopes:
  scope :applied,  -> { where.not(applied_at: nil) }
  scope :clicked,  -> { where.not(clicked_at: nil) }
  scope :declined, -> { where.not(declined_at: nil) }
  scope :denied,   -> { where.not(denied_at: nil) }
  scope :expired,  -> { where.not(expired_at: nil) }
  scope :nudged,   -> { where.not(nudged_at: nil) }
  scope :open,     -> { where.not(opened_at: nil) }
  scope :pulled,   -> { where.not(pulled_at: nil) }
  scope :redenied, -> { where.not(redenied_at: nil) }
  scope :seen,     -> { where.not(seen_at: nil) }

  # basic 'timestamp not present' scopes:
  scope :unapplied,  -> { where(applied_at: nil) }
  scope :unclicked,  -> { where(clicked_at: nil) }
  scope :undeclined, -> { where(declined_at: nil) }
  scope :undenied,   -> { where(denied_at: nil) }
  scope :unexpired,  -> { where(expired_at: nil) }
  scope :unnudged,   -> { where(nudged_at: nil) }
  scope :unopen,     -> { where(opened_at: nil) }
  scope :unpulled,   -> { where(pulled_at: nil) }
  scope :unredenied, -> { where(redenied_at: nil) }
  scope :unseen,     -> { where(seen_at: nil) }
  scope :unclosed,   -> { where(closed_at: nil) }

  # compound scopes:

  # Recommendations which have been denied and we don't encourage the user to
  # call for reconsideration. (In other words, recommendations which have been
  # denied after calling or denied after nudging
  scope :irreversibly_denied, -> { recommendations.redenied.or(denied.nudged) }

  # Not the best name (any better ideas?), but the opposite of
  # irreversibly_denied. Any recommendation which HASN'T been
  # irreversibly_denied, including recommendations which haven't been denied at
  # all in any sense.
  scope :not_irreversibly_denied, -> do
    recommendations.where(%["denied_at" IS NULL OR "nudged_at" IS NULL]).unredenied
  end

  # Recommendations which still require user action:
  scope :resolved, -> do
    pulled.or(open).or(expired).or(irreversibly_denied).recommendations
  end

  # Recommendations which no longer require user action:
  scope :unresolved, -> do
    recommendations.unpulled.unopen.not_irreversibly_denied.unexpired
  end

  # Recommendations which the user can still see:
  scope :visible, -> { recommendations.undeclined.unexpired.unpulled }

  def pull!
    update_attributes!(pulled_at: Time.now)
  end

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
