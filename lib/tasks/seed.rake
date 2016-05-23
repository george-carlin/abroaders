namespace :ab do
  namespace :seeds do

    def load_data_for(table)
      seeds_dir = Rails.root.join("lib", "seeds")
      JSON.parse(File.read(seeds_dir.join("#{table}.json")))
    end

    task admins: :environment do
      ApplicationRecord.transaction do
        %w[Erik AJ George].each do |name|
          Admin.create!(
            email: "#{name.downcase}@abroaders.com",
            password:              "abroaders123",
            password_confirmation: "abroaders123"
          )
        end
        puts "created #{Admin.count} admins"
      end
    end

    task cards: :environment do
      ApplicationRecord.transaction do
        load_data_for("cards").each do |data|
          data["image"] = File.open(
            Rails.root.join("lib", "seeds", "cards", data.delete("image_name"))
          )
          Card.create!(data)
        end
        puts "created #{Card.count} cards"
      end
    end

    task offers: :environment do
      ApplicationRecord.transaction do
        load_data_for("offers").each do |data|
          Offer.create!(data)
        end
        puts "created #{Offer.count} cards"
      end
    end

    task currencies: :environment do
      ApplicationRecord.transaction do
        load_data_for("currencies").each do |data|
          Currency.create!(data)
        end
        puts "created #{Currency.count} currencies"
      end
    end

    task destinations: :environment do
      require 'csv'

      if Destination.any?
        puts "There are already destinations in the DB"
      end

      Destination.transaction do

        # ------ REGIONS ------

        regions_csv  = File.read(Rails.root.join("lib/data/regions.csv"))
        regions_data = CSV.parse(regions_csv)
        puts "Importing #{regions_data.length} regions..."
        @regions = regions_data.map do |name, code|
          Destination.region.create!(name: name, code: code)
        end

        @regions = @regions.index_by(&:name)

        # ------ COUNTRIES ------

        # To see the file where I got the original data from, visit:
        #
        # https://bitbucket.org/!api/2.0/snippets/georgemillo/kEb9y/b160569a4ea16a450c4a3aa02b5fcd9865dea269/files/snippet.txt
        #
        # Originally I had a rake task at lib/tasks/download_countries.rake (dig
        # it out of the git history if you're interested) which grabbed this
        # file, changed a few things, then saved it as a CSV locally, but since
        # then I've edited the resulting CSV substantially (added some missing
        # countries, removed some 'countries' that are just uninhabited islands
        # with no airport, and added regions), to the extent that there's no
        # point concerning ourselves iwth the original online data anymore.

        countries_csv  = File.read(Rails.root.join("lib/data/countries.csv"))
        countries_data = CSV.parse(countries_csv)
        countries_data.shift # remove the column headers
        puts "Importing #{countries_data.length} countries..."
        @countries = countries_data.map do |name, code, region_name|
          Destination.countries.create!(
            name: name,
            code: code,
            parent: @regions.fetch(region_name)
          )
        end

        # Create a hash of countries with the code as the key and the Country
        # as the value
        @countries = @countries.index_by(&:code)

        # ------ STATES ------

        states_csv = File.read(Rails.root.join("lib/data/state_data.csv"))
        states_data = CSV.parse(states_csv)
        states_data.shift # remove the column headers
        puts "Importing #{states_data.length} states..."
        @states = states_data.map do |name, code, parent_code|
          Destination.states.create!(
            name: name,
            code: code,
            parent: @countries.fetch(parent_code)
          )
        end

        # Create a hash of states with the code as the key and the State
        # as the value
        @states = @states.index_by(&:code)

        # ------ CITIES ------

        cities_csv = File.read(Rails.root.join("lib/data/city_data.csv"))
        cities_data = CSV.parse(cities_csv)
        cities_data.shift # remove the column headers
        puts "Importing #{cities_data.length} cities..."
        @cities = cities_data.map do |name, code, state_code, country_code|
          Destination.cities.create!(
            name: name,
            code: code,
            parent: @states[state_code] || @countries[country_code]
          )
        end

        # Create a hash of cities with the code as the key and the State
        # as the value
        @cities = @cities.index_by(&:code)

        # ------ AIRPORTS ------

        airports_csv = File.read(Rails.root.join("lib/data/airport_data.csv"))
        airports_data = CSV.parse(airports_csv)
        airports_data.shift # remove the column headers
        puts "Importing #{airports_data.length} airports..."
        @airports = airports_data.map do |name, code, city, state, country|
          Destination.airports.create!(
            name:   name,
            code:   code,
            parent: @cities[city] || @states[state] || @countries[country]
          )
        end
      end # transaction
    end

    task all: [:admins, :currencies, :cards, :destinations, :offers]

  end
end
