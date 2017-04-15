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

  def status
    # Note: the order of these return statements matters!
    return 'opened'      if opened?
    return 'pulled'      unless pulled_at.nil?
    return 'expired'     if expired?
    return 'declined'    if declined?
    return 'denied'      unless denied_at.nil?
    return 'applied'     unless applied_on.nil?
    return 'recommended' unless recommended_at.nil?
    raise "couldn't determine recommendation status"
  end

  property :id

  # For explanations of what all these properties are, see the comments in
  # Card and CardAccount
  property :recommended_at
  property :applied_on
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
  alias_method :card_product, :product

  delegate :opened?, :unopened?, to: :model

  def self.find(*args)
    new(Card.recommended.find(*args))
  end

  # Put these in a module so we can include them in Card too. Temp solution
  # until I've made all the refactorings I want to make to CardRecommendation
  module Predicates
    %w[
      seen_at clicked_at applied_on declined_at denied_at expired_at nudged_at
      called_at pulled_at redenied_at
    ].each do |attr|
      state = attr.sub(/_at\z/, '').sub(/_on\z/, '') << '?'
      define_method state do
        !send(attr).nil?
      end

      define_method "un#{state}" do
        send(attr).nil?
      end
    end
  end
  include Predicates

  def unopen?
    warn 'CardRecommendation#unopen? is deprecated. Use #unopened?'
    unopened?
  end

  def actionable?
    unpulled? && unopened? && unredenied? && unredenied? && unexpired? && undeclined? &&
      (undenied? || unnudged?)
  end
end
