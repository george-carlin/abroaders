namespace :ab do
  task :download_airports_and_cities do
    require 'csv'

    # Found a CSV files on line with a biiig list of airport data.
    # The problem is that it doesn't contain the IATA code for the *city*,
    # just the name of the 'municipality', which isn't specific enough.
    # So I found another file which maps IATA airport codes to IATA city codes.
    #
    # This rake task downloads both files, strips out any columns we don't
    # care about, and saves the data to a single CSV file.


    # ------ Get the data that maps IATA airport codes to city codes -----

    city_codes_uri = URI.parse(
      "https://bitbucket.org/!api/2.0/snippets/georgemillo/y8zMo/"\
      "8ec4454bc955b27ee278ad92187e046c548312fb/files/snippet.txt"
    )

    raw_city_code_data = Net::HTTP.get_response(city_codes_uri)
    city_code_data = CSV.parse(raw_city_code_data.body.force_encoding("utf-8"))
    # Remove the headers (they're "Location", "City", "Airport")
    city_code_data.shift

    # The current data set doesn't tell us which city is in which
    # state/country; we have to infer this from the 'airport' dataset. For now,
    # create a hash with the airport codes as keys and the city codes as values
    # (for use when saving the airports), and we'll come back and save the city
    # data later.

    city_codes_by_airport = city_code_data.each_with_object({}) do |row, h|
      city_code    = row[1]
      airport_code = row[2]
      h[airport_code] = city_code
    end

    # ------ Get the airport dataset: -----
    airport_data_uri = URI.parse(
      "https://bitbucket.org/!api/2.0/snippets/georgemillo/"\
      "Ad9Mb/1852d0a5ba78f4f061d9cd754c02c627b7e643da/files/file"
    )

    # Raw data is in UTF-8 but Net::HTTP interprets it as ASCII, so fix the
    # encoding before attempting to parse as CSV:
    raw_airport_data = Net::HTTP.get_response(airport_data_uri)
    airport_data     = CSV.parse(raw_airport_data.body.force_encoding("utf-8"))
    # Remove the headers:
    airport_data.shift

    # (the headers are:)
    # id ident type name latitude_deg longitude_deg elevation_ft continent
    # iso_country iso_region municipality scheduled_service gps_code iata_code
    # local_code home_link wikipedia_link keywords

    # ----- Combine it all into one dataset -------

    # This dataset is huge and contains info about heliports, private airports,
    # and tiny airports that we don't care about, as some as some
    # duplicate or nonsensical data. Filter out irrelevant stuff.
    #
    # First remove rows which don't have a valid IATA code (this removes
    # well over 50% of the rows in the dataset):
    airports = airport_data.select do |row|
      name = row[3]
      code = row[13]

      name.present? && !name.include?("[Duplicate]") &&
        code.present? && code =~ /\A[A-Z]{3}\z/i
    end

    # Also, some IATA codes appear twice for airports with different
    # names. The few of these that I've Googled seem to be tiny regional
    # airports, cargo airports etc, some of them no longer operational.  For
    # now just reject any data which has an IATA code which appears more than
    # once.
    codes_which_appear_more_than_once = airports.map do |row|
      row[13]
    end.group_by { |c| c }.select { |_, v| v.size > 1 }.keys.sort

    airports.reject! do |row|
      codes_which_appear_more_than_once.include?(row[13])
    end

    # Now package it all up into a dataset that only includes the columns
    # we actually need:

    airports = airports.map do |row|
      name = row[3]
      code = row[13]
      city_code    = city_codes_by_airport[code]
      # If we don't know an airport's city, we'll save its 'parent' as
      # its state, or, failing that, its country:
      state_code   = row[9]
      country_code = row[8]
      [name, code, city_code, state_code, country_code]
    end

    # Now create hashes mapping city code to state code and country code (if we
    # don't know the state that a city belongs to, we'll give it a parent
    # country)

    state_codes_by_city = airports.each_with_object({}) do |row, h|
      city_code    = row[2]
      state_code   = row[3]
      h[city_code] = state_code
    end
    country_codes_by_city = airports.each_with_object({}) do |row, h|
      city_code    = row[2]
      country_code = row[4]
      h[city_code] = country_code
    end


    # Note that what we call 'states', IATA calls 'regions', but to us a
    # 'region' is a group of countries, not a subdivision within a country.

    # Add headers:
    airports.unshift(
      ["name", "code", "city_code", "state_code", "country_code"]
    )

    # ------ Save to CSV -----

    path = File.expand_path("../../data/airport_data.csv", __FILE__)
    # => (rails_root)/lib/data/airport_data.csv

    CSV.open(path, "w") do |csv|
      airports.each { |airport| csv << airport }
    end
    puts "Saved data to #{path}"

    cities_data = city_code_data.select do |row|
      # Here's the dumb way we're doing it - if the airport code is the same 
      # as the city code (which is true for the vast majority of rows in the
      # dataset), assume that the "Location" name is the city name. Else,
      # skip this row.
      #
      # See e.g. the data for the New York airports:
      #
      # "New York",NYC,NYC
      # "New York, John F. Kennedy",NYC,JFK
      # "New York, La Guardia",NYC,LGA
      # "New York, Newark",NYC,EWR
      #
      # "NYC" is the general IATA code for all New York airports
      #
      # See also "London":
      #
      # "London",LON,LON
      # "London",YXU,YXU
      # "London, Gatwick",LON,LGW
      # "London, Heathrow",LON,LHR
      # "London, City Airport",LON,LCY
      # "London, Luton",LON,ETN
      # "London, Stansted",LON,STN
      #
      # LON means London, England, while YXU means London, Ontario
      #
      # This approach isn't perfect, however. See "Toronto" :
      #
      # "Toronto",YTO,YTO
      # "Toronto",YYZ,YYZ
      #
      # "YTO" is the metrocode for all of Toronto, while "YYZ" is Toronto
      # Pearson Airport. (There are other airports in Toronto, but they
      # aren't included in this dataset :( )
      #
      # We'll work around this by, in the rake task that saves Airports
      # and Cities to the DB, deleting any Cities that don't have any
      # child airports (which in this case would by YTO)
      #
      # Note that the list of 'metrocodes' (codes which cover more than one
      # airport) is actually fairly small, so if there are major issues we can
      # probably fix things up manually.
      # See http://wikitravel.org/en/Metropolitan_Area_Airport_Codes
      #
      row[1] == row[2]
    end.map do |row|
      name    = row[0]
      code    = row[1]
      state   = state_codes_by_city[code]
      country = country_codes_by_city[code]
      [name, code, state, country]
    end

    # Add the 'headers' row:
    cities_data.unshift %w[name code state country]

    # Save the cities data as CSV
    path = File.expand_path("../../data/city_data.csv", __FILE__)
    # => (rails_root)/lib/data/city_data.csv

    CSV.open(path, "w") do |csv|
      cities_data.each { |city| csv << city }
    end

    puts "Saved data to #{path}"

  end
end

