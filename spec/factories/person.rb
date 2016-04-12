FactoryGirl.define do
  factory :person, aliases: [:main_passenger] do
    account
    first_name { Faker::Name.first_name }

    # TODO everything below this line needs a serious audit!
    main true

    trait :main do
      main true
    end

    trait :companion do
      main false
    end

    trait :with_spending do
      after(:build) do |person|
        person.build_spending_info(attributes_for(:spending_info, person: nil))
      end
    end

    trait :onboarded do
      with_spending_info
      onboarded_balances true
      onboarded_cards true
      after(:build) do |person|
        person.build_readiness_status(ready: true)
      end
    end

    factory :companion,                    traits: [:companion]
    factory :person_with_spending,         traits: [:with_spending]
    factory :main_passenger_with_spending, traits: [:with_spending, :main]
    factory :companion_with_spending,      traits: [:with_spending, :companion]
  end
end
