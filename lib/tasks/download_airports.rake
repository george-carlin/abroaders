namespace :ab do
  task :download_airports do
    require 'csv'

    def valid_airport_code?(code)
      code.present? && code =~ /\A[A-Z]{3}\z/i
    end

    def valid_airport_name?(name)
      name.present? && !name.include?("[Duplicate]")
    end

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
      "999e043d8b01578b730ba2f9d58d13072c506eba/files/snippet.txt"
    )

    raw_city_code_data = Net::HTTP.get_response(city_codes_uri)
    city_code_data = CSV.parse(raw_city_code_data.body.force_encoding("utf-8"))
    cc_col_headers = city_code_data.shift
    # => %w[Location City Airport]

    airport_col = cc_col_headers.index("City")
    city_col    = cc_col_headers.index("Airport")

    airport_code_to_city_code = city_code_data.each_with_object({}) do |row, h|
      h[row[airport_col]] = row[city_col]
    end

    # ------ Get the bigger data set with the other info -----

    airport_data_uri = URI.parse(
      "https://bitbucket.org/!api/2.0/snippets/georgemillo/"\
      "Ad9Mb/1852d0a5ba78f4f061d9cd754c02c627b7e643da/files/file"
    )

    # Raw data is in UTF-8 but Net::HTTP interprets it as ASCII, so fix the
    # encoding before attempting to parse as CSV:
    raw_airport_data = Net::HTTP.get_response(airport_data_uri)
    airport_data     = CSV.parse(raw_airport_data.body.force_encoding("utf-8"))
    ad_col_headers   = airport_data.shift

    name_col    = ad_col_headers.index("name")
    code_col    = ad_col_headers.index("iata_code")
    country_col = ad_col_headers.index("iso_country")

    # ----- Combine it all into one dataset -------

    final_data = airport_data.map do |airport|
      code = airport[code_col]
      name = airport[name_col]
      # For now, skip any airports which a) don't have an IATA code or
      # b) the other dataset doesn't have a city code for them
      unless valid_airport_code?(code) && 
              airport_code_to_city_code.key?(code) &&
              valid_airport_name?(name)
        next
      end
      [
        name,
        code,
        airport_code_to_city_code[code],
        airport[country_col]
      ]
    end.compact

    final_data.unshift(
      ["name", "iata_code", "iata_city_code", "iso_country_code"]
    )

    # ------ Save to CSV -----

    path = File.expand_path("../../data/airport_data.csv", __FILE__)
    # => (rails_root)/lib/data/airport_data.csv

    CSV.open(path, "w") do |csv|
      final_data.each { |airport| csv << airport }
    end

    puts "Saved data to #{path}"
  end
end

