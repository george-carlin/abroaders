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
end
