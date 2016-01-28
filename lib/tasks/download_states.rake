namespace :ab do
  task :download_states do
    require 'csv'

    uri = URI.parse(
      "https://bitbucket.org/!api/2.0/snippets/georgemillo/nLz96/"\
      "788ae2a499a78a81706505e32ed08167a27e2ba9/files/snippet.txt"
    )

    puts "Downloading CSV data..."
    response = Net::HTTP.get_response(uri)
    # Raw data is in UTF-8 but Net::HTTP interprets it as ASCII, so fix the
    # encoding before attempting to parse as CSV:
    data = CSV.parse(response.body.force_encoding("utf-8"))
    column_headers = data.shift
    # # => %w[ COUNTRY NAME, ISO 3166-2 SUB-DIVISION/STATE CODE, ISO 3166-2
    #          SUBDIVISION/STATE NAME, ISO 3166-2 PRIMARY LEVEL NAME,
    #          SUBDIVISION/STATE ALTERNATE NAMES, ISO 3166-2
    #          SUBDIVISION/STATE CODE (WITH *), SUBDIVISION CDH ID, COUNTRY
    #          CDH ID, COUNTRY ISO CHAR 2 CODE, COUNTRY ISO CHAR 3 CODE ]

    puts "Downloaded data about #{data.length} states."

    # Remove all except the columns we actually care about:

    name_col_index = column_headers.index("ISO 3166-2 SUBDIVISION/STATE NAME")
    code_col_index = column_headers.index("ISO 3166-2 SUB-DIVISION/STATE CODE")
    country_code_col_index = column_headers.index("COUNTRY ISO CHAR 2 CODE")

    trimmed_data = data.map do |country|
      [
        country[name_col_index],
        country[code_col_index],
        country[country_code_col_index]
      ]
    end

    trimmed_data.unshift(["name", "iso_code", "iso_country_code"])

    path = File.expand_path("../../data/state_data.csv", __FILE__)
    # => (rails_root)/lib/data/state_data.csv

    CSV.open(path, "w") do |csv|
      trimmed_data.each { |state| csv << state }
    end

    puts "Saved data to #{path}"
  end
end

