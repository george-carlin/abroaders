namespace :ab do
  # API docs (you can't see them unless you have access to the Abroaders GDrive):
  #   https://drive.google.com/open?id=0Bw1kKbr9pYkcNGl1MVFJb0xORWpIaEhjMTRMNVg5emF2R3dz
  namespace :wallaby do
    task :setup do
      require "httparty"
      require "active_support/all"

      BASE_URL = "https://api-qa.wallabyfinancial.net/v4".freeze
      HEADERS = {
        "X-Wasapi-App-Id"  => "22dd50c2",
        # NOTE: The current API key will expire sometime in April 2016, and we
        # won't get a new one without paying.
        "X-Wasapi-App-Key" => ENV["WALLABY_APP_KEY"],
        "Content-Type"     => "application/json",
      }.freeze
    end

    task scrape_cards: :setup do
      cards = []

      # Default limit is 10, max is 100
      query = { "limit" => 100, "offset" => 0 }

      loop do
        puts "getting cards #{query['offset']} to "\
             "#{query['offset'] + query['limit'] - 1}..."
        response = HTTParty.get("#{BASE_URL}/cards", query: query, headers: HEADERS)

        new_cards = JSON.parse(response.body)
        puts "downloaded #{new_cards.length} cards:"
        cards += new_cards
        break if new_cards.length < query["limit"]
        query["offset"] = query["offset"] += query["limit"]
      end

      path = File.expand_path("../../data/wallaby_cards.json", __FILE__)
      puts "Writing to #{path}..."
      File.write(path, JSON.pretty_generate(cards))
      puts "Written!"
    end

    task scrape_banks: :setup do
      banks = []

      # Default limit is 10, max is 100
      query = { "limit" => 100, "offset" => 0 }

      loop do
        puts "getting banks #{query['offset']} to "\
             "#{query['offset'] + query['limit'] - 1}..."
        response = HTTParty.get("#{BASE_URL}/banks", query: query, headers: HEADERS)

        new_banks = JSON.parse(response.body)
        puts "downloaded #{new_banks.length} banks:"
        banks += new_banks
        break if new_banks.length < query["limit"]
        query["offset"] = query["offset"] += query["limit"]
      end

      path = File.expand_path("../../data/wallaby_banks.json", __FILE__)
      puts "Writing to #{path}..."
      File.write(path, JSON.pretty_generate(banks))
      puts "Written!"
    end

    task scrape_all: [:scrape_banks, :scrape_cards]
  end
end
