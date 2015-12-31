# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ApplicationRecord.transaction do
  unless User.admin.any?
    %w[Erik AJ George].each do |name|
      User.admin.create!(
        name:  name,
        email: "#{name.downcase}@abroaders.com",
        password:              "abroaders123",
        password_confirmation: "abroaders123",
        confirmed_at: Time.now
      )
    end
  end
end
