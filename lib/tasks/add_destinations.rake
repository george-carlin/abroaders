namespace :ab do
  task add_destinations: :environment do
    require 'csv'

    if Destination.any?
      puts "There are already destinations in the DB"
    end

    Destination.transaction do

      # ------ COUNTRIES ------

      countries_csv = File.read(Rails.root.join("lib/data/country_data.csv"))
      countries_data = CSV.parse(countries_csv)
      countries_data.shift # remove the column headers
      puts "Importing #{countries_data.length} countries..."
      @countries = countries_data.map do |country|
        Destination.countries.create!(
          name: country[0],
          code: country[1]
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
