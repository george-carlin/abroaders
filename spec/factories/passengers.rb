FactoryGirl.define do
  factory :passenger, aliases: [:main_passenger] do
    account
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
      spending_info
    end
    # Potential contribution to FactoryGirl, allow for traits to be aliased
    trait :with_spending do
      spending_info
    end

    factory :companion,                    traits: [:companion]
    factory :passenger_with_spending,      traits: [:with_spending]
    factory :main_passenger_with_spending, traits: [:with_spending, :main]
    factory :companion_with_spending,      traits: [:with_spending, :companion]
  end
end
