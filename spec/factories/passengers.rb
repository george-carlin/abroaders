FactoryGirl.define do
  factory :passenger do
    account
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    time_zone    { ActiveSupport::TimeZone.us_zones.sample.name }
    credit_score do
      min = Survey::MINIMUM_CREDIT_SCORE
      max = Survey::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
    personal_spending { rand(1000) + 9000 }

    trait :completed_card_survey do
      has_added_cards true
    end

    trait :complete do
      has_added_cards    true
      has_added_balances true
    end
  end
end
