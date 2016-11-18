require 'seeder'

# TODO extract the rest of these to the 'Seeder' module
namespace :ab do
  namespace :seeds do

    # Some of our original airport and city data was taken from here:
    #
    # https://bitbucket.org/!api/2.0/snippets/georgemillo/y8zMo/8ec4454bc955b27ee278ad92187e046c548312fb/files/snippet.txt
    # and
    # https://bitbucket.org/!api/2.0/snippets/georgemillo/Ad9Mb/1852d0a5ba78f4f061d9cd754c02c627b7e643da/files/file
    #
    # But it's been heavily changed/edited since then, and our current airport
    # data is mostly based on miles.biz's list of airports (as of 25/10/2016).
    # Keep the note of the above links just for historical reference.

    task admins: :environment do
      ApplicationRecord.transaction do
        %w[Erik AJ George].each do |name|
          Admin.create!(
            email: "#{name.downcase}@abroaders.com",
            password:              "abroaders123",
            password_confirmation: "abroaders123",
          )
        end
        puts "created #{Admin.count} admins"
      end
    end

    task alliances: :environment do
      Seeder.seed_alliances
    end

    task banks: :environment do
      [
        # comments after each line contain additional data about the bank
        # that we're not doing anything with yet
        [1, 'Chase', '(888) 609-7805', '800 453-9719'],
        [3, 'Citibank', '(800) 695-5171', '800-763-9795'],
        [5, 'Barclays', '866-408-4064', '866-408-4064'],
        # hours: 8am-5pm EST M-F
        [7, 'American Express', '(877) 399-3083', '(877) 399-3083'],
        # when prompted, say 'Application Status'
        [9, 'Capital One', '(800) 625-7866', '(800) 625-7866'],
        # hours (M-F 8-8pm EST)
        [11, 'Bank of America', '(877) 721-9405', '800-481-8277'],
        # when prompted, dial option 3 for 'Application Status'
        [13, 'US Bank', '800 685-7680', '800 685-7680'],
        # hours: 8am-8pm EST (M-F)'
        [15, 'Discover'],
        [17, 'Diners Club'],
        [19, 'SunTrust'],
        [21, 'TD Bank'],
        [23, 'Wells Fargo'],
      ].each do |id, name, personal_phone, business_phone|
        Bank.create!(
          business_phone: business_phone,
          id:             id,
          identifier:     identifier,
          name:           name,
          personal_phone: personal_phone,
        )
      end
    end

    task cards: :environment do
      ApplicationRecord.transaction do
        currency_ids = Currency.pluck(:id)
        Seeder.load_data_for("cards").each do |data|
          data["image"] = File.open(
            Rails.root.join("lib", "seeds", "cards", data.delete("image_name")),
          )
          data["currency_id"] = currency_ids.sample
          Card::Product.create!(data)
        end
        puts "created #{Card::Product.count} cards"
      end
    end

    task offers: :environment do
      ApplicationRecord.transaction do
        Seeder.load_data_for("offers").each do |data|
          Offer.create!(data)
        end
        puts "created #{Offer.count} offers"
      end
    end

    task currencies: :environment do
      Seeder.seed_currencies
    end

    task regions: :environment do
      ApplicationRecord.transaction do
        csv  = File.read(Rails.root.join("lib/data/regions.csv"))
        data = CSV.parse(csv)
        data.each { |name, code| Region.create!(name: name, code: code) }
        puts "created #{data.length} regions"
      end
    end

    task countries: :environment do
      ApplicationRecord.transaction do
        regions = Region.all.index_by(&:name)
        csv     = File.read(Rails.root.join("lib/data/countries.csv"))
        data    = CSV.parse(csv)
        data.shift # remove the column headers
        data.each do |name, code, region_name|
          Country.create!(
            name:   name,
            code:   code,
            parent: regions.fetch(region_name),
          )
        end
        puts "created #{data.length} countries"
      end
    end

    # Note that this doesn't add *every* city. Some airports in airports.csv
    # don't belong to a city which can be found in cities.csv, in which case we
    # add the city in the 'airports' rake task and make up a code for the city.
    # (City codes don't really matter, we don't have to make some exactly match
    # some external ISO standard because they're for our own internal use
    # only.)
    task cities: :environment do
      ApplicationRecord.transaction do
        countries = Country.all.index_by(&:code)
        data = CSV.parse(File.read(Rails.root.join("lib/data/cities.csv")))
        data.shift # remove the column headers
        data.each do |code, country_code, name|
          City.create!(name: name, code: code, parent: countries[country_code])
        end
        puts "created #{data.length} cities"
      end
    end

    task airports: :environment do
      # Airport data is taken from Miles.biz - we have the original raw data
      # from them in Google Drive somewhere.
      #
      # See the comment above regarding airports in airports.csv for
      # which there is no city.
      ApplicationRecord.transaction do
        cities = City.all.index_by(&:code)
        data = CSV.parse(File.read(Rails.root.join("lib/data/airports.csv")))
        data.shift # remove the column headers
        data.each do |code, city_code, name|
          Airport.create!(name: name, code: code, parent: cities[city_code])
        end
        puts "created #{data.length} airports"
      end # transaction
    end

    task destinations: [:regions, :countries, :cities, :airports]
    task all: [:admins, :currencies, :cards, :destinations, :offers]
  end
end
