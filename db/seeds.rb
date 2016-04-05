ApplicationRecord.transaction do
  if Currency.any? || Admin.any? || CardOffer.any? || Card.any?
    puts "you already have data in the DB"
    next
  end

  %w[Erik AJ George].each do |name|
    email = "#{name.downcase}@abroaders.com"
    unless Admin.exists?(email: email)
      Admin.create!(
        email: email,
        password:              "abroaders123",
        password_confirmation: "abroaders123"
      )
    end
  end
  puts "created #{Admin.count} admins"

  seeds_dir = Rails.root.join("lib", "seeds")

  # Import currencies
  JSON.parse(File.read(seeds_dir.join("currencies.json"))).each do |data|
    Currency.create!(data)
  end
  puts "created #{Currency.count} currencies"

  # Import cards
  JSON.parse(File.read(seeds_dir.join("cards.json"))).each do |data|
    Card.create!(data)
  end
  puts "created #{Card.count} cards"

  # Import offers
  JSON.parse(File.read(seeds_dir.join("card_offers.json"))).each do |data|
    CardOffer.create!(data)
  end
  puts "created #{CardOffer.count} cards"
end
