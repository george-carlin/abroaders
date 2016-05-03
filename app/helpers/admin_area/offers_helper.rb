module AdminArea
  module OffersHelper

    def options_for_offer_condition_select(offer)
      options_for_select(
        Offer.conditions.each_with_object({}) do |(key, _), hash|
          hash[t("activerecord.attributes.offer.conditions.#{key}")] = key
        end,
        offer.condition
      )
    end

  end
end
