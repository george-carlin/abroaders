# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ApplicationRecord.transaction do

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

  # `rake ab:sample_data:users`

end
