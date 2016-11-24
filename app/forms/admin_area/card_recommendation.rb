module AdminArea
  class CardRecommendation < ApplicationForm
    attribute :offer_id, Integer
    attribute :person,   Person

    # The card account that is created on save:
    attribute :card, Card

    validate :offer_is_live

    def self.name
      'Card'
    end

    def offer
      # Not sure why, but if you don't put "::" in front of "Offer" then
      # you get an error saying 'A copy of AdminArea::CardRecommendation has been
      # removed from the module tree but is still active'
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
