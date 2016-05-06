namespace :ab do
  namespace :export do
    task cards: :environment do
      card_data = Card.find_each.map do |card|
        card.as_json.slice(
          "shown_on_survey",
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
        puts "WARNING: Using this rake task on Heroku may not do what you "\
             "think it does. See comment in code."
        # Turns out that Heroku has some kind of upper limit on how many
        # characters can be printed and returned to your local terminal when
        # you use `heroku run`... so if you have too many cards/offers in the
        # DB then not all of them will be printed by Heroku. You have been
        # warned.
        puts json.gsub( /\r\n?/, "\n")
      else
        path = Rails.root.join("lib/data/cards.json")
        File.write(path, json)
        puts "cards data saved to #{path}"
      end
    end

    task offers: :environment do
      offer_data = Offer.find_each.map do |offer|
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
        puts "WARNING: Using this rake task on Heroku may not do what you "\
             "think it does. See comment in code."
        # Turns out that Heroku has some kind of upper limit on how many
        # characters can be printed and returned to your local terminal when
        # you use `heroku run`... so if you have too many cards/offers in the
        # DB then not all of them will be printed by Heroku. You have been
        # warned.
        puts json.gsub( /\r\n?/, "\n")
      else
        path = Rails.root.join("lib/data/offers.json")
        File.write(path, json)
        puts "cards data saved to #{path}"
      end
    end
  end
end
