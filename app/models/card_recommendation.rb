# Eventually we're going to split the `cards` table into separate tables called
# `cards`, `card_recommendations`, and possibly `card_applications`. In the
# meantime, 'CardRecommendation' the twin can fill in for CardRecommendation
# the ActiveRecord model. Try to make this class as future-proof as possible
class CardRecommendation < Disposable::Twin
  include ActiveModel::Naming
  feature Save
  feature Sync

  # @param card [Card]
  def initialize(card, options = {})
    raise 'card is not a recommendation' if card.recommended_at.nil?
    super
  end

  def pull!
    self.pulled_at = Time.now
    sync
    model.save!
  end

  property :id

  # The time the admin recommended the product to the user. non-nullable
  property :recommended_at

  # The time the user *first* saw this recommendation (by visiting /cards)
  property :seen_at

  # The time the user *first* clicked the 'Find My Card' button. Note that we don't
  # know for sure that they actually applied, just that they clicked the link.
  # (We have to rely on them coming back and telling us that they applied).
  property :clicked_at

  # For whatever reason, a user might not want to apply for the card we
  # recommend to them. If that's the case, they have option to 'decline' the
  # card and tell us why. This timestamp tells us when they declined.
  property :declined_at

  # The reason why the user declined the rec. Users can't decline a rec without
  # giving us a reason why.
  property :decline_reason

  # Recs which are not clicked within 15 days are assumed to be declined.  For
  # the sake of record-keeping, we note this in a separate time column, rather
  # than reusing 'declined_at' (which would make it unclear whether the user
  # declined the card manually or it was declined automatically).
  #
  # Note that 'expiry' in this sense has nothing to do with the expiry date
  # that's printed on a bank card.
  property :expired_at

  # 'pulled' means that the admin withdrew the rec after making it.
  property :pulled_at

  # The date the user *applied* for the card (according to them).
  property :applied_on

  # If the user applied for the card but their application was denied,
  # this timestamp tells us when.
  property :denied_at

  # If the user applies for the card but doesn't hear back immediately, we
  # encourage them to call the bank to speed up the application process.  If
  # they tell us they've called, then 'nudged_at' is the date they called.
  # Note that nudged_at is distinct from 'called_at', explained below:
  #
  # If the user applies and is *denied* (as opposed to just not having heard
  # back yet), we also encourage them to call and see if the application can be
  # reconsidered. In this case we set the called_at timestamp, not the
  # nudged_at timestamp.
  #
  # So in brief: a 'nudge' is when they call the bank about a *pending*
  # application. A 'call' is when they call the bank about a *denied*
  # application. (If they nudge and then are denied, we don't encourage them to
  # call again. They should only call if the application was denied without
  # nudging. So nudged_at and called_at will never both be present)
  #
  # NOTE: the distinction between 'nudging' and 'calling' is a code-level thing
  # that should only matter to developers. From the point of view of the
  # business and the non-technical stakeholders, both actions are considered to
  # be 'calling', and non-developers don't need to know about the terminology
  # 'nudge'. We're using this internal distinction because it makes it much
  # easier to track a user's actions and figure out where they are in the
  # application survey.
  property :nudged_at
  property :called_at

  # If the user is denied, calls, and gets denied again, 'redenied_at' is the
  # date they were denied for the second time. We need this column for two
  # reasons: 1) it's the only way to distinguish between a user who has called
  # for reconsideration, and a user who has been denied again after calling for
  # reconsideration - and 2) we need to preserve the original denied_at
  # timestamp because that's what determines when the user can apply again
  property :redenied_at

  def self.all(*args)
    Card.recommendations.where(args).map { |c| new(c) }
  end

  def self.find(*args)
    new(Card.recommendations.find(*args))
  end
end
