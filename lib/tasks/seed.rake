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
        puts "created #{Offer.count} offers"
      end
    end

    task currencies: :environment do
      # Note that we have the following currencies in FieldBook, but we're
      # not currently including them in the Rails app:
      #  - Aegean Airlines (Miles & Bonus)
      #  - Aer Lingus (Gold Circle)
      #  - Aeroflot Bonus
      #  - Aerolineas Argentinas (Plus)
      #  - Brussels Airlines (LOOPs)
      #  - China Airlines (Dynasty Flyer)
      #  - Copa Airlines ConnectMiles (Prefer)
      #  - Czech Airlines (OK Plus)
      #  - EL AL Israel Airlines (Matmid)
      #  - Ethiopian Airlines (ShebaMiles)
      #  - Finnair Plus
      #  - Garuda Indonesia (Frequent Flyer)
      #  - Royal Jordanian Airlines (Royal Plus)
      #  - S7 Priority
      #  - Saudi Arabian Airlines (Alfursan)
      #  - South African Airways (Voyager)
      #  - SriLankan (FlySmiLes)
      #  - Turkish Airlines (Miles & Smiles)
      #  - Ukraine International Airlines (Panorama Club)
      #  - Vietnam Airlines (Golden Lotus Plus)
      ApplicationRecord.transaction do
        load_data_for("currencies").each do |data|
          alliance_name = data.delete("alliance")
          data["alliance_id"] = Alliance.find_by(name: alliance_name).id if alliance_name
          Currency.create!(data)
        end
        puts "created #{Currency.count} currencies"
      end
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
            parent: regions.fetch(region_name)
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
