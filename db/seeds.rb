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
        email: "#{name.downcase}@abroaders.com",
        password:              "abroaders123",
        password_confirmation: "abroaders123",
        confirmed_at: Time.now
      )
    end
  end

  unless User.non_admin.any?
    50.times do
      name = Faker::Name.first_name
      u = User.create!(
        email: "#{name.parameterize}@example.com",
        password:              "abroaders123",
        password_confirmation: "abroaders123"
      )
      if rand > 0.3
        u.create_contact_info!(
          phone_number: Faker::PhoneNumber.phone_number,
          first_name: name,
          middle_names: (Faker::Name.first_name if rand > 0.1),
          last_name: Faker::Name.last_name,
          whatsapp: rand > 0.4,
          text_message: rand > 0.1,
          imessage: rand > 0.7
        )
      end
    end
  end
end
