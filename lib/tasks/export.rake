namespace :ab do
  namespace :export do
    task cards: :environment do
      card_data = Card.find_each.map do |card|
        card.as_json.slice(
          "active",
          "annual_fee_cents",
          "bank_id",
          "bp",
          "currency_id",
          "code",
          "id",
          "image_name",
          "name",
          "network",
          "type",
          "wallaby_id",
        )
      end

      File.write(Rails.root.join("lib/data/cards.json"), JSON.pretty_generate(card_data))
    end

    task offers: :environment do
      offer_data = CardOffer.find_each.map do |offer|
        offer.as_json.slice(
          "card_id",
          "condition",
          "cost",
          "days",
          "id",
          "link",
          "notes",
          "points_awarded",
          "spend",
          "status",
        )
      end

      File.write(Rails.root.join("lib/data/card_offers.json"), JSON.pretty_generate(offer_data))
    end
  end
end
