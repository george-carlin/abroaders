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
        puts "created #{Offer.count} cards"
      end
    end

    task currencies: :environment do
      ApplicationRecord.transaction do
        load_data_for("currencies").each do |data|
          Currency.create!(data)
        end
        puts "created #{Currency.count} currencies"
      end
    end

    # TODO this still doesn't import destinations, you'll need to call those
    # rake tasks separately.
    task all: [:admins, :currencies, :cards, :offers]
  end
end
