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

  # For explanations of what all these properties are, see the comments in
  # Card and CardAccount
  property :recommended_at
  property :seen_at
  property :clicked_at
  property :declined_at
  property :decline_reason
  property :expired_at
  property :pulled_at
  property :applied_on
  property :denied_at
  property :nudged_at
  property :called_at
  property :redenied_at

  property :product

  def self.find(*args)
    new(Card.recommended.find(*args))
  end
end
