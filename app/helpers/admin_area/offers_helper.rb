module AdminArea
  module OffersHelper

    def options_for_offer_card_select
      options_for_select(
        Card.order("name ASC").map do |card|
          [
            [
              card.bank_name,
              card.name,
              card.bp,
              I18n.t("activerecord.attributes.card.networks.#{card.network}")
            ].join(" "),
            card.id,
          ]
        end
      )
    end

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
