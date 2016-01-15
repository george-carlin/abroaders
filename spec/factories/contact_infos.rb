FactoryGirl.define do
  factory :contact_info do
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    time_zone    { %w[GMT PDT PST UTC CET MST MDT WST EST].sample }
  end
end
