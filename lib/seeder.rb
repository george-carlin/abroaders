# This module is used by seed.rake. Extracting the code to a module rather than
# keeping it all within the rake task(s) for ease of testing.
module Seeder
  def self.seed_admins
    %w[Erik AJ George].each do |name|
      Admin.create!(
        email: "#{name.downcase}@abroaders.com",
        name: name,
        password: 'abroaders123',
        password_confirmation: 'abroaders123',
        avatar: File.open(Rails.root.join('lib', 'avatars', "#{name.downcase}.jpg")),
      )
    end
    Rails.logger.info "created #{Admin.count} admins"
  end

  def self.seed_card_products
    raise "can't seed card products with no currencies in the DB" unless Currency.any?
    currency_ids = Currency.pluck(:id)
    bank_ids = Bank.all.pluck(:id)
    # the card products in this JSON file don't necessarily correspond to card
    # products that exist in real life. Originally they did, but we don't need
    # to keep a hyper-accurate list of cards in the repo anymore; that's what
    # the production DB is for. So I've massively cut the size of
    # card_products.json for the sake of making the seeds run faster, and
    # changed the attributes of some of the remaining products for the sake of
    # diversity.
    Seeder.load_data_for('card_products').each do |data|
      data['image'] = File.open(
        Rails.root.join('lib', 'seeds', 'card_products', data.delete('image_name')),
      )
      data['personal'] = data.delete('bp') == 'personal'
      data['currency_id'] = currency_ids.sample
      data['bank_id']     = bank_ids.sample
      CardProduct.create!(data)
    end
    Rails.logger.info "created #{CardProduct.count} cards"
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
    ApplicationRecord.transaction do
      load_data_for("currencies").each do |data|
        data["alliance_name"] = data.delete("alliance") || 'Independent'
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
