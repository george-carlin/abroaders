# This module is used by seed.rake. Extracting the code to a module rather than
# keeping it all within the rake task(s) for ease of testing.
module Seeder
  def self.seed_admins
    %w[Erik AJ George].each do |name|
      Admin.create!(
        email: "#{name.downcase}@abroaders.com",
        password:              "abroaders123",
        password_confirmation: "abroaders123",
      )
    end
    Rails.logger.info "created #{Admin.count} admins"
  end

  def self.seed_alliances
    ApplicationRecord.transaction do
      [
        [1, 'OneWorld',     0],
        [2, 'StarAlliance', 1],
        [3, 'SkyTeam',      2],
        [4, 'Independent',  99],
      ].each do |id, name, order|
        Alliance.create!(id: id, name: name, order: order)
      end
      Rails.logger.info "created #{Alliance.count} alliances"
    end
  end

  def self.seed_banks
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
    ].each do |code, name, personal_phone, business_phone|
      Bank.create!(
        business_phone: business_phone,
        personal_code:  code,
        name:           name,
        personal_phone: personal_phone,
      )
    end
  end

  def self.seed_card_products
    raise "can't seed card products with no currencies in the DB" unless Currency.any?
    raise "can't seed card products with no banks in the DB" unless Bank.any?
    currency_ids = Currency.pluck(:id)
    bank_ids = Bank.pluck(:id)
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
      data['currency_id'] = currency_ids.sample
      data['bank_id']     = bank_ids.sample
      Card::Product.create!(data)
    end
    Rails.logger.info "created #{Card::Product.count} cards"
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
      alliances = Alliance.all.each_with_object({}) { |a, h| h[a.name] = a }
      load_data_for("currencies").each do |data|
        alliance_name = data.delete("alliance")
        data["alliance_id"] = if alliance_name
                                alliances[alliance_name].id
                              else
                                alliances['Independent'].id
                              end
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
