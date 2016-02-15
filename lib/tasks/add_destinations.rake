namespace :ab do
  task add_destinations: :environment do
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
      @states = states_data.map do |state|
        Destination.states.create!(
          name: state[0],
          code: state[1],
          parent: @countries.fetch(state[2])
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
      @cities = cities_data.map do |city|
        # TODO Some cities in the data don't have a parent state or country -
        # this is probably due to data being missing in the original CSVs I got
        # the data from. See the 'download_airports_and_cities' rake task
        state_code   = city[2]
        country_code = city[3]
        Destination.cities.create!(
          name: city[0],
          code: city[1],
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
      @airports = airports_data.map do |airport|
        # TODO Some airports in the data don't have a parent state or country -
        # this is probably due to data being missing in the original CSVs I got
        # the data from. See the 'download_airports_and_airports' rake task
        city_code    = airport[2]
        state_code   = airport[3]
        country_code = airport[4]
        parent = @cities[city_code] || @states[state_code] || @countries[country_code]
        Destination.airports.create!(
          name: airport[0],
          code: airport[1],
          parent: parent
        )
      end
    end # transaction
  end
end
