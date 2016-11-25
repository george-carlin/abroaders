module AdminArea
  class Recommendation < ApplicationForm
    attribute :offer_id, Integer
    attribute :person,   Person

    # The card account that is created on save:
    attribute :card, Card

    validate :offer_is_live

    def self.model_name
      ::Recommendation.model_name
    end

    def offer
      @offer ||= ::Offer.find(offer_id)
    end

    private

    def offer_is_live
      errors.add(:offer, "must be live") unless offer.live?
    end

    def persist!
      self.card = person.card_recommendations.create!(offer: offer, recommended_at: Time.now)
    end
  end
end
