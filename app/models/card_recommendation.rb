class CardRecommendation < Disposable::Twin
  include ActiveModel::Naming
  feature Save
  feature Sync

  # @param card [Card]
  def initialize(card, options = {})
    raise 'card is not a recommendation' unless card.recommended?
    super
  end

  def status
    # Note: the order of these return statements matters!
    return 'opened'      if opened?
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
  property :applied_on
  property :denied_at
  property :nudged_at
  property :called_at
  property :redenied_at

  property :card_product
  property :offer
  property :person

  delegate :opened?, :unopened?, to: :model

  # use an instance method instead of `property` otherwise #initialize will
  # crash if the underlying card has no bank (e.g. in tests)
  def bank_name
    bank&.name
  end

  def self.find(*args)
    new(Card.recommended.find(*args))
  end

  # This is necessary to generate correct URLs if you want to pass an instance
  # of CardRecommendation to a routes helper.
  def to_param
    id.to_s
  end

  # Put these in a module so we can include them in Card too. Temp solution
  # until I've made all the refactorings I want to make to CardRecommendation
  module Predicates
    %w[
      seen_at clicked_at applied_on declined_at denied_at expired_at nudged_at
      called_at redenied_at
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

  def actionable?
    unopened? && unredenied? && unredenied? && unexpired? && undeclined? &&
      (undenied? || unnudged?)
  end

  def unresolved?
    unapplied? && unexpired? && undeclined?
  end
end
