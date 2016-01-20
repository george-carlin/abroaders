FactoryGirl.define do
  factory :user_info do
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    time_zone    { %w[GMT PDT PST UTC CET MST MDT WST EST].sample }
    credit_score do
      min = UserInfo::MINIMUM_CREDIT_SCORE
      max = UserInfo::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
    spending_per_month_dollars { rand(1000) + 9000 }
  end
end
