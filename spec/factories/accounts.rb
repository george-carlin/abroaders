FactoryGirl.define do
  factory :account, aliases: [:confirmed_account] do
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
      # SURVEYTODO
      after(:build) do |account|
        account.build_survey(
          attributes_for(
            :survey, account: nil,
            first_name: account.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end

    trait :completed_card_survey do
      after(:build) do |account|
        account.build_survey(
          attributes_for(
            :survey,
            :completed_card_survey,
            account: nil,
            first_name: account.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end

    trait :survey_complete do
      after(:build) do |account|
        account.build_survey(
          attributes_for(
            :survey,
            :complete,
            account: nil,
            first_name: account.email.split("@").first.sub(/-\d+/, "").capitalize
          )
        )
      end
    end
  end
end
