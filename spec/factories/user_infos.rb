FactoryGirl.define do
  factory :user_info do
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    time_zone    { ActiveSupport::TimeZone.us_zones.sample.name }
    credit_score do
      min = UserInfo::MINIMUM_CREDIT_SCORE
      max = UserInfo::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
    personal_spending { rand(1000) + 9000 }
  end
end
