# This module is used by seed.rake. Extracting the code to a module rather than
# keeping it all within the rake task(s) for ease of testing.
module Seeder
  def self.seed_alliances
    ApplicationRecord.transaction do
      [
        [1, 'OneWorld'],
        [2, 'StarAlliance'],
        [3, 'SkyTeam'],
      ].each do |id, name|
        Alliance.create!(id: id, name: name)
      end
      Rails.logger.info "created #{Alliance.count} alliances"
    end
  end

  def self.seed_currencies
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
    raise "can't add currencies with no alliances in DB" unless Alliance.any?
    ApplicationRecord.transaction do
      load_data_for("currencies").each do |data|
        alliance_name = data.delete("alliance")
        data["alliance_id"] = Alliance.find_by(name: alliance_name).id if alliance_name
        if data["award_wallet_id"] == "unknown"
          # AW ids must be present and unique:
          data["award_wallet_id"] << "-#{SecureRandom.hex}"
        end
        Currency.create!(data)
      end
      Rails.logger.info "created #{Currency.count} currencies"
    end
  end

  # TODO the files which contain the sample data are split between lib/seeds
  # and lib/data for no apparent reason. Standardise where they're kept.
  def self.load_data_for(table)
    seeds_dir = Rails.root.join("lib", "seeds")
    JSON.parse(File.read(seeds_dir.join("#{table}.json")))
  end
end
