namespace :ab do
  task add_airports: :environment do
    require 'csv'

    # Print a 'percentage complete' display with width 50
    def percentage_complete_display(done, total)
      pc_complete   = (100 * done) / total
      no_of_filled_spaces = pc_complete/2
      print "#{"#"*no_of_filled_spaces}#{" "*(50 - no_of_filled_spaces)} "\
            "#{pc_complete}% (#{done}/#{total})\r"
    end

    Airport.transaction do
      # Note that, at the time of writing, there are 47,358 airports in this
      # CSV file, so this task might take a while!

      # This data was taken from http://ourairports.com/data/airports.csv,
      # backed up to my own Bitbucket account in case the original disappears.
      uri = URI.parse(
        "https://bitbucket.org/!api/2.0/snippets/georgemillo/"\
        "Ad9Mb/1852d0a5ba78f4f061d9cd754c02c627b7e643da/files/file"
      )
      airports_data = CSV.parse(Net::HTTP.get_response(uri).body)

      # 'airports_data' is an Array of Arrays. Each inner Array contains data
      # about a single airport (or a 'balloonport', helipad, etc)

      airport_headers = airports_data.shift

      uri = "https://raw.githubusercontent.com/datasets/country-codes/master/data/country-codes.csv"

      iso_country_codes = CSV.parse(
        Net::HTTP.get_response(
          URI.parse(
            "https://raw.githubusercontent.com/datasets/country-codes/master/"\
            "data/country-codes.csv"
          )
        ).body
      )

      index_of_name_col = airport_headers.index("name")
      index_of_iata_col = airport_headers.index("iata_code")
      index_of_country_code_col = airport_headers.index("iso_country")

      airports_data.select! do |airport_data|
        # Check the IATA code is valid (i.e. is 3 letters), rather than just
        # checking that it's present, because some of the rows in the data
        # don't make sense.
        iata_code = airport_data[index_of_iata_col]
        iata_code.present? && iata_code =~ Airport::IATA_CODE_REGEX
      end

      
      # Also, some IATA codes appear twice for airports with different
      # names. The few of these that I've Googled seem to be tiny regional
      # airports, cargo airports etc, some of them no longer operational.  For
      # now just reject any data which has an IATA code which appears more than
      # once.
      codes_which_appear_more_than_once = airports_data.map do |a|
        a[index_of_iata_col]
      end.group_by { |c| c }.select { |_, v| v.size > 1 }.keys

      airports_data.reject! do |airport|
        codes_which_appear_more_than_once.include?(airport[index_of_iata_col])
      end

      puts "Importing information about #{airports_data.length} airports..."

      tick_size = airports_data.length / 100

      airports_data.each_with_index do |airport_data, i|
        if i % tick_size == 0
          percentage_complete_display(i, airports_data.length)
        end

        Airport.create!(
          name:      airport_data[index_of_name_col],
          iata_code: airport_data[index_of_iata_col]
        )
      end
      # Print this out again to make sure that '100%' gets printed (otherwise
      # it will only be printed if airports_data.length is an exact multiple
      # of tick_size:
      percentage_complete_display(airports_data.length, airports_data.length)
      print "\n"
      puts "Import complete!"
    end
  end
end
