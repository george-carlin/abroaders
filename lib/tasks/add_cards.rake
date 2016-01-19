namespace :ab do
  task add_cards: :environment do
    require "net/http"
    require "uri"
    require "json"

    book_id = "558c49ac95d9a30300e8d8e8"
    url     = "https://api.fieldbook.com/v1/#{book_id}/cards"

    key    = ENV["FIELDBOOK_API_KEY"]
    secret = ENV["FIELDBOOK_API_SECRET"]

    uri = URI.parse(url)

    http    = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(key, secret)
    http.use_ssl = true

    puts "Querying the Fieldbook API..."

    response = http.request(request)
    cards = JSON.parse(response.body)

    puts "Downloaded info about #{cards.length} cards"

    brands = { "V" => :visa, "M" => :mastercard, "A" => :amex }
    bps    = { "B" => :business, "P" => :personal }

    Card.transaction do
      before_count = Card.count

      cards.each do |card|

        unless name  = card["card_name"]
          puts "Skipping a card with no name"
          next
        end
        unless brand = card["brand"]
          puts "Skipping #{name} as it has no brand"
          next
        end
        unless af = card["af"]
          puts "Skipping #{name} as it has no annual fee specified"
          next
        end
        unless brand = brands[card["brand"]]
          puts "Skipping #{name} as it has no annual fee specified"
          next
        end

        card = Card.create!(
          identifier: card["card_id"],
          name:       card["card_name"],
          brand:      brand,
          bp:         bps.fetch(card["b_p"]),
          type:       card["type"].downcase,
          annual_fee_cents: af * 100,
          bank:  card["bank"][0]["bank_name"].downcase.gsub(/\s/, "_")
        )

        puts "Created card '#{card.name}'"
      end # cards.each

      puts "---------"
      puts "Created #{Card.count - before_count} cards in total"
    end # transaction

  end
end
