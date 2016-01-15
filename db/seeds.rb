# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ApplicationRecord.transaction do
  include FactoryGirl::Syntax::Methods

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
      date = ((500).days + rand(24).hours + rand(60).minutes).ago
      args = [:user, { created_at: date, confirmed_at: date } ]
      args.insert(1, :with_contact_info) if rand > 0.2
      user = build(*args)

      if user.contact_info.present?
        user.contact_info.assign_attributes(
          middle_names: (Faker::Name.first_name if rand > 0.1),
          whatsapp: rand > 0.4,
          text_message: rand > 0.1,
          imessage: rand > 0.7,
        )
      end

      user.save!
    end
  end
end
