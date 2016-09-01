module AdminArea
  class CardRecommendation < ApplicationForm
    attribute :offer_id, Fixnum
    attribute :person,   Person

    validate :offer_is_live

    private

    def offer
      @offer ||= Offer.find(offer_id)
    end

    def offer_is_live
      errors.add(:offer, "must be live") unless offer.live?
    end

    def persist!
      person.card_recommendations.create!(offer: offer, recommended_at: Time.now)
    end
  end
end
