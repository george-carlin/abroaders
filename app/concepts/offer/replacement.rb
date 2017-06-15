class Offer < Offer.superclass
  # TODO add docs
  class Replacement
    def self.call(offer)
      new(offer).()
    end

    def initialize(offer)
      @offer = offer
    end

    def call
      query = {
        card_product_id: @offer.card_product_id,
        condition: @offer.condition,
        cost: @offer.cost,
      }

      query[:spend] = @offer.spend if Condition.spend?(@offer.condition)
      query[:days] = @offer.days if Condition.days?(@offer.condition)

      if Condition.points_awarded?(@offer.condition)
        query[:points_awarded] = @offer.points_awarded
      end

      Offer.where(query).where.not(id: @offer.id).first
    end
  end
end
