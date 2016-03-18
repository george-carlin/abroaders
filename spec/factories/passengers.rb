FactoryGirl.define do
  factory :passenger, aliases: [:main_passenger] do
    association :account, factory: :account, onboarding_stage: "spending"
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    main true

    trait :main do
      main true
    end

    trait :companion do
      main false
    end

    trait :with_spending_info do
      association :account, factory: :account, onboarding_stage: "cards"
      spending_info
    end
    # Potential contribution to FactoryGirl, allow for traits to be aliased
    trait :with_spending do
      association :account, factory: :account, onboarding_stage: "cards"
      spending_info
    end

    trait :onboarded do
      with_spending_info
      association :account, factory: :account, onboarding_stage: "onboarded"
    end

    factory :companion,                    traits: [:companion]
    factory :passenger_with_spending,      traits: [:with_spending]
    factory :main_passenger_with_spending, traits: [:with_spending, :main]
    factory :companion_with_spending,      traits: [:with_spending, :companion]
  end
end
