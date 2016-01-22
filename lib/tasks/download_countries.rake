namespace :ab do
  task :download_countries do
    require 'csv'

    uri = URI.parse(
      "https://bitbucket.org/!api/2.0/snippets/georgemillo/kEb9y/"\
      "b160569a4ea16a450c4a3aa02b5fcd9865dea269/files/snippet.txt"
    )

    puts "Downloading CSV data..."
    response = Net::HTTP.get_response(uri)

    # Raw data is in UTF-8 but Net::HTTP interprets it as ASCII, so fix the
    # encoding before attempting to parse as CSV:
    data = CSV.parse(response.body.force_encoding("utf-8"))
    column_headers = data.shift
    # # => %w[name, name_fr, ISO3166-1-Alpha-2, ISO3166-1-Alpha-3,
    #        ISO3166-1-numeric, ITU, MARC, WMO, DS, Dial, FIFA, FIPS, GAUL,
    #        IOC, currency_alphabetic_code, currency_country_name,
    #        currency_minor_unit, currency_name, currency_numeric_code,
    #        is_independent]

    puts "Downloaded data about #{data.length} countries."

    # Remove all except the columns we actually care about:

    name_col_index = column_headers.index("name")
    code_col_index = column_headers.index("ISO3166-1-Alpha-2")

    trimmed_data = data.map do |country|
      [country[name_col_index], country[code_col_index]]
    end

    trimmed_data.unshift(["name", "iso_code"])

    path = File.expand_path("../../data/country_data.csv", __FILE__)
    # => (rails_root)/lib/data/country_data.csv

    CSV.open(path, "w") do |csv|
      trimmed_data.each { |country| csv << country }
    end

    puts "Saved data to #{path}"
  end
end
