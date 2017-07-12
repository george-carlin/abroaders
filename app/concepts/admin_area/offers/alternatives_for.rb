module AdminArea::Offers
  # Takes an offer and returns all its *alternatives*, defined as offers
  # which are:
  #
  #   - not the exact same offer, i.e. have different `id`
  #   - have the same card product
  #   - have the same condition
  #   - have the same cost
  #   - have the same days
  #   - have the same spend
  #   - have the same points_awarded
  #   - are live and recommendable
  #
  # Other attrs e.g. `partner` and `value` are irrelevant.
  #
  # Conceptually, two offers are 'alternatives' if they're functionally
  # identical from the point of view of the person receiving the recs.
  # Whichever offer they apply for, they'll get the same card and the same
  # bonus based on the same card. The only difference is stuff that only
  # admins see and care about, e.g. the affiliate partner.
  #
  # This is used to find offers which be safely 'swapped out' for another (if
  # e.g. one offer has become unavailable since recommended it) while
  # minimising disruption for the user.
  #
  # Note: this query will only return recommendable (i.e. live) offers,
  # but it can take a non-recommendable offer as its param.
  class AlternativesFor
    # @return [Array<Offer>]
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

      query[:spend] = @offer.spend if Offer::Condition.spend?(@offer.condition)
      query[:days] = @offer.days if Offer::Condition.days?(@offer.condition)

      if Offer::Condition.points_awarded?(@offer.condition)
        query[:points_awarded] = @offer.points_awarded
      end

      Offer.recommendable.where(query).where.not(id: @offer.id)
    end
  end
end
