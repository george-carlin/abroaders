module AdminArea
  module CardOfferHelper

    def options_for_card_offer_card_select
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

    def options_for_card_offer_condition_select(offer)
      options_for_select(
        CardOffer.conditions.each_with_object({}) do |(key, _), hash|
          hash[t("activerecord.attributes.card_offer.conditions.#{key}")] = key
        end,
        offer.condition
      )
    end

  end
end
