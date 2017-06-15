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
      conditions = {
        card_product_id: @offer.card_product_id,
        condition: @offer.condition,
        cost: @offer.cost,
      }

      unless @offer.condition == 'on_minimum_spend'
        conditions[:spend] = @offer.spend
      end

      if %w[on_first_purchase on_minimum_spend].include?(@offer.condition)
        conditions[:days] = @offer.days
      end

      unless @offer.condition == 'no_bonus'
        conditions[:points_awarded] = @offer.points_awarded
      end

      Offer.where(conditions).where.not(id: @offer.id).first
    end
  end
end
