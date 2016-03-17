FactoryGirl.define do
  factory :account do
    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"
    confirmed_at           "2015-01-01"

    trait :passenger do
      onboarding_stage "spending"
      after(:build) do |account|
        account.build_main_passenger(attributes_for(:passenger, account: nil))
      end
    end

    trait :companion do
      onboarding_stage "spending"
      after(:build) do |account|
        account.build_companion(attributes_for(:companion, account: nil))
      end
    end

    # This line won't work:
    #
    #   FactoryGirl.create(:account, :spending)
    #
    # But this will:
    #
    #   FactoryGirl.create(:account, :passenger, :spending)
    #
    # Note that order matters. This will fail:
    #
    #   FactoryGirl.create(:account, :spending, :passenger)
    #
    trait :spending do
      onboarding_stage "main_passenger_cards"
      after(:build) do |account|
        account.main_passenger.build_spending_info(
          attributes_for(:spending_info, passenger: nil)
        )
      end
    end

    trait :companion_spending do
      onboarding_stage "main_passenger_cards"
      after(:build) do |account|
        account.companion.build_spending_info(
          attributes_for(:spending_info, passenger: nil)
        )
      end
    end

    factory :onboarded_account, traits: [:passenger, :spending] do
      onboarding_stage "onboarded"
    end

    factory(
      :onboarded_companion_account,
      traits: [:passenger, :spending, :companion, :companion_spending]
    ) do
      onboarding_stage "onboarded"
    end
  end
end
