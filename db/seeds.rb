ApplicationRecord.transaction do
  if Currency.any? || Admin.any? || CardOffer.any? || Card.any?
    puts "you already have data in the DB"
    next
  end

  `rake ab:seeds:all`
end
