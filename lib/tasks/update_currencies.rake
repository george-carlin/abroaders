namespace :ab do
  desc "update the currenices in the DB based on currencies.json"
  task update_currencies: :environment do
    currencies = JSON.parse(File.read(Rails.root.join("lib/seeds/currencies.json")))

    Currency.transaction do
      alliances = {
        "OneWorld" => 1,
        "StarAlliance" => 2,
        "SkyTeam" => 3,
      }

      currencies.each do |data|
        if alliance = data.delete("alliance")
          data["alliance_id"] = alliances[alliance]
        end
        if data["award_wallet_id"] == "unknown"
          # award wallet ID must be present, and unique
          data["award_wallet_id"] << "-#{SecureRandom.hex}"
        end
        curr = Currency.find_or_initialize_by(name: data["name"])
        curr.update_attributes!(data)
      end
    end
  end
end
