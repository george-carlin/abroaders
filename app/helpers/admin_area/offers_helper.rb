module AdminArea
  module OffersHelper
    def options_for_offer_condition_select(offer)
      options_for_select(
        ::Offer.conditions.each_with_object({}) do |(key, _), hash|
          hash[t("activerecord.attributes.offer.conditions.#{key}")] = key
        end,
        offer.condition,
      )
    end

    def options_for_offer_partner_select(offer)
      options_for_select(
        ::Offer.partners.keys.map do |key|
          name = case key
                 when "card_ratings" then "CardRatings.com"
                 when "credit_cards" then "CreditCards.com"
                 when "award_wallet" then "AwardWallet"
                 when "card_benefit" then "CardBenefit"
                 end

          [name, key]
        end,
        offer.partner,
      )
    end
  end
end
