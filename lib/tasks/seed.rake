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
      Seeder.seed_admins
    end

    task alliances: :environment do
      Seeder.seed_alliances
    end

    task banks: :environment do
      Seeder.seed_banks
    end

    task card_products: :environment do
      Seeder.seed_card_products
    end

    task offers: :environment do
      ApplicationRecord.transaction do
        product_ids = CardProduct.pluck(:id)
        Seeder.load_data_for("offers").each do |data|
          data['product_id'] = product_ids.sample
          data['link']       = 'http://example.com'
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
    task all: [:admins, :alliances, :banks, :currencies, :card_products, :destinations, :offers]
  end
end
