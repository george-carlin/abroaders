FactoryGirl.define do
  factory :account do
    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"
    confirmed_at           "2015-01-01"

    # TODO everything below this line needs a serious audit!

    # We can't name this trait 'passenger' because it conflicts with
    # the 'passenger' factory, causing subtle errors. I raised this as
    # an issue with FactoryGirl, see
    # https://github.com/thoughtbot/factory_girl/issues/885
    trait :with_passenger do
      onboarding_stage "spending"
      after(:build) do |account|
        account.build_main_passenger(attributes_for(:passenger, account: nil))
      end
    end

    trait :with_companion do
      with_passenger
      after(:build) do |account|
        account.build_companion(attributes_for(:companion, account: nil))
      end
    end

    trait :spending do
      with_passenger
      onboarding_stage "main_passenger_cards"
      after(:build) do |account|
        account.main_passenger.build_spending_info(
          attributes_for(:spending_info, passenger: nil)
        )
      end
    end

    trait :companion_spending do
      spending
      with_companion
      after(:build) do |account|
        account.companion.build_spending_info(
          attributes_for(:spending_info, passenger: nil)
        )
      end
    end

    # Note: using this trait in isolation is probably a bad idea as you'll get
    # an account whose onboarding_stage is 'onboarded' but who doesn't have any
    # Passengers or SpendingInfos (i.e. an account that couldn't actually exist
    # given the normal operation of the app)
    trait :onboarded do
      spending
      onboarding_stage "onboarded"
    end

    trait :onboarded_companion do
      companion_spending
      onboarded
    end

    factory :onboarded_account, traits: [:onboarded]
    factory :onboarded_companion_account, traits: [:onboarded_companion]
  end
end
