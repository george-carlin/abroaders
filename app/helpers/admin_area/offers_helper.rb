module AdminArea
  module OffersHelper

  # Argh! Duplicated in so many places! TODO
  def card_name(card)
    return "" unless card
    [
      card.bank_name,
      card.name,
      card.bp,
      I18n.t("activerecord.attributes.card.networks.#{card.network}")
    ].join(" ")
  end

    def options_for_offer_card_select(offer)
      cards = Card.order("name ASC").map { |card| [ card_name(card), card.id ] }
      options_for_select cards.sort_by { |c| c[0] }, offer.card_id
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
