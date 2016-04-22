FactoryGirl.define do
  factory :person, aliases: [:main_passenger] do
    association(:account, factory: :account, with_person: false)
    first_name { Faker::Name.first_name }

    trait :eligible do
      after(:build) { |person| person.eligible_to_apply! }
    end

    trait :ineligible do
      after(:build) { |person| person.ineligible_to_apply! }
    end

    main true

    trait :main do
      main true
    end

    trait :companion do
      main false
    end

    trait :onboarded_spending do
      eligible
      after(:build) do |person|
        person.build_spending_info(attributes_for(:spending_info, person: nil))
      end
    end

    # TODO everything below this line needs a serious audit!

    trait :onboarded do
      with_spending_info
      onboarded_balances true
      onboarded_cards true
      after(:build) do |person|
        person.build_readiness_status(ready: true)
      end
    end

    factory :companion,                    traits: [:companion]
    factory :person_with_spending,         traits: [:onboarded_spending]
    factory :main_passenger_with_spending, traits: [:onboarded_spending, :main]
    factory :companion_with_spending,      traits: [:onboarded_spending, :companion]
  end
end
