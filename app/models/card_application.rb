# An application to a bank to open a particular card account. At present, the
# only way for an application to be created is for a user to tell us that
# they've applied for a card we recommended to them. In future users will
# also be able to tell us about other card applications they've made.
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
class CardApplication < ApplicationRecord
  belongs_to :card
  belongs_to :offer
  has_one :card_recommendation
  has_one :product, through: :offer
  belongs_to :person

  def card_recommendation=(new_rec)
    unless new_rec.offer.nil?
      if !offer.nil? && new_rec.offer != offer
        raise "offers don't match"
      else
        self.offer = new_rec.offer
      end
    end

    unless new_rec.person.nil?
      if !person.nil? && new_rec.person != person
        raise "people don't match"
      else
        self.person = new_rec.person
      end
    end

    super
  end

  # Possible return values: 'applied', 'denied', 'called', 'approved',
  # 'refused'.  'refused' means that the application has been denied with no
  # possbility of reconsideration (i.e. they were denied after nudging, or they
  # were redenied after being denied and calling.)
  #
  # This method doesn't care about the distinction between 'nudging' and
  # 'calling'; both have the status 'calling'.
  def status
    return 'approved' if approved?
    return 'refused' if redenied?
    return 'called'  if called?

    return nudged? ? 'refused' : 'denied' if denied?

    return 'called' if nudged?
    'applied'
  end

  def approved?
    card.present?
  end

  def called?
    !called_at.nil?
  end

  def denied?
    !denied_at.nil?
  end

  def nudged?
    !nudged_at.nil?
  end

  def redenied?
    !redenied_at.nil?
  end
end
