namespace :ab do
  namespace :setup do
    desc "populate the DB with initial cards, offers, and currencies"

    task cards: :environment do
      ApplicationRecord.transaction do
        # When we launch the MVP, this rake task will be used to add the initial
        # set of Cards, Currencies, and CardOffers.
        #
        # Here's how this list was created/chosen:
        #
        # 1. Scraped all card data from the Wallaby API - it's in
        #    `lib/data/wallaby_cards.json`. (Note that we only had a temporary
        #    sandbox API key which may have expired by the time you read this.)
        #
        # 2. Filtered out all cards except those that are from the following
        #    list of banks:
        #     - American Express
        #     - Bank of America
        #     - Barclays
        #     - Capital One
        #     - Chase
        #     - Citibank
        #     - Diners Club
        #     - Discover
        #     - SunTrust
        #     - TD Bank
        #     - US Bank
        #     - Wells Fargo
        #
        # 3. Erik reviewed the remaining cards manually to decide which cards
        #    to include.  He also found some offers for these cards - maximum
        #    one offer per card, some cards have no offer.
        #
        #    The CSV file below contains those selected cards and their offers.
        #    Each row of the CSV contains the details of one card, and
        #    optionally of one offer for that card:
        #

        path = Rails.root.join("lib","data","selected_wallaby_cards_with_offers.csv")
        card_data = CSV.parse(File.read(path))

        # remove the 'headers' row.
        card_data.shift
        # Headers:
        #   Bank, Card Name,AF,Brand,Currency,Award Wallet Currency,Wallaby
        #   Key,BP,,Bonus,Spend ,Days,Cost,Link,Active ,Notes

        # currency_names = card_data.map { |c| c[4] }.uniq.sort

        # puts currency_names
        # next
        # # Create currencies:
        # currencies = currency_names.each_with_index.map do |currency_name, i|
        #   # TODO: find out the award wallet ID of each currency. (Using
        #   # a placeholder value for now)
        #   Currency.create!(name: currency_name, award_wallet_id: i)
        # end.index_by(&:name)

        banks      = Bank.all.index_by(&:name)
        currencies = Currency.all.index_by(&:name)

        # wallaby_data = JSON.parse(Rails.root.join("lib","data","wallaby_cards.json"))

        image_from_dir = Rails.root.join("lib/data/card_images")
        image_dest_dir = Rails.root.join("lib/card_images")

        card_data.each do |card|
          name = card[1]
          # Generate a 2-4 letter code from the card's name:
          words = name.downcase.delete("®").delete("&").delete("/").strip.split
          # Don't use common or non-descriptive words for the code:
          %w[the card from credit].each { |word| words.delete(word) }
          # This just provides an approximation for a descriptive code. The
          # admin can always change them himself in the web interface later.

          if words.length == 1
            code = words.first[0..1].upcase
          else
            code = words.first(3).map { |w| w[0].upcase }.join
          end

          network = card[3].downcase
          network = case card[3].downcase
                    when "american express" then "amex"
                    when "unknown" then "unknown_network"
                    else
                      card[3].downcase
                    end
          raise network unless Card.networks.keys.include?(network)

          bp = card[7] == "B" ? "business" : "personal"
          currency_id = currencies[card[5]].id
          bank_id     = banks[card[0]].id

          # All wallaby cards have a network. If network is unknown, it's
          # because wallaby had a visa and mastercard version of the same card,
          # but we found and offer where we didn't know which card it referred
          # to. Leave the wallaby ID blank in this case to avoid confusion with
          # the 'real' wallaby card.
          #
          # However, we still need to use the wallaby ID to find the card
          # image, as that's how our files are named locally.
          wallaby_id = (card[6] unless network == "unknown")

          if card[6] == "custom"
            image_name = card[1] + ".png"
          else
            image_name = card[6] + ".png"
          end

          # Copy the image over:
          #FileUtils.cp(
            #image_from_dir.join(image_name),
            #image_dest_dir.join(image_name),
          #)

          new_card = Card.create!(
            name: name,
            code: code,
            network: network,
            bp: bp,
            currency_id: currency_id,
            bank_id:     bank_id,
            annual_fee_cents: (card[2].delete("$").to_f * 100).to_i,
            type: "unknown_type",
            wallaby_id: wallaby_id,
            image_name: image_name,
          )

          if card[9] # present if there is an offer
            puts card[12]
            case card[12].downcase
            when "first purchase"
              condition = :on_first_purchase
              spend = 0
              days  = card[13] ? card[13].to_i : 90
            when "approval"
              condition = :on_approval
              spend = 0
              days  = 0
            else
              condition = :on_minimum_spend
              spend = card[12].to_i
              days = card[13].to_i
            end

            begin
            new_card.offers.create!(
              points_awarded: card[11].to_i,
              condition: condition,
              spend:  spend,
              cost:   card[14].to_i,
              days:   days,
              status: (card[16].downcase == "yes" ? "live" : "expired"),
              link:   card[15],
              notes:  card[18],
            )
            rescue
              raise condition.to_s
            end
          end
        end

        #   # The data from the CSV is a string like '$X.XX':

        #   Card.create!(
        #     code: code,
        #     name: card[1],
        #     network:
        #     t.integer  "bp",                              null: false
        #     t.integer  "type",                            null: false
        #     t.integer  "annual_fee_cents",                null: false
        #     annual_fee_cents: cards[2].delete("$").to_f * 100).to_i
        #     # t.boolean  "active",           default: true, null: false
        #     currency: currencies[card[4]],
        #     t.integer  "bank_id",                         null: false
        #   )
        # end

        # bank_names = cards.map { |c| c[0] }.uniq.sort

        # puts bank_names
        # raise
      end
    end
  end
end
