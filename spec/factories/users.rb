FactoryGirl.define do
  factory :user, aliases: [:confirmed_user] do
    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"
    confirmed_at           "2015-01-01"

    factory :admin do
      admin true
    end

    trait :completed_main_survey do
      after(:build) do |user|
        user.build_survey(
          attributes_for(
            :survey, user: nil,
            first_name: user.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end

    trait :completed_card_survey do
      after(:build) do |user|
        user.build_survey(
          attributes_for(
            :survey,
            :completed_card_survey,
            user: nil,
            first_name: user.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end

    trait :survey_complete do
      after(:build) do |user|
        user.build_survey(
          attributes_for(
            :survey,
            :complete,
            user: nil,
            first_name: user.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end
  end
end
