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

      json = JSON.pretty_generate(card_data)

      if ENV["PRINT_ON_EXPORT"]
        puts json.gsub( /\r\n?/, "\n")
      else
        path = Rails.root.join("lib/data/cards.json")
        File.write(path, json)
        puts "cards data saved to #{path}"
      end
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

      json = JSON.pretty_generate(offer_data)

      if ENV["PRINT_ON_EXPORT"]
        puts json.gsub( /\r\n?/, "\n")
      else
        path = Rails.root.join("lib/data/card_offers.json")
        File.write(path, json)
        puts "cards data saved to #{path}"
      end
    end
  end
end
