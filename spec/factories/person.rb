FactoryGirl.define do
  factory :person, aliases: [:owner] do
    association(:account, factory: :account, with_person: false)
    first_name { Faker::Name.first_name }

    trait :eligible do
      eligible true
    end

    trait :ineligible do
      eligible false
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

    trait :onboarded_cards do
      onboarded_spending
      onboarded_cards true
    end

    trait :onboarded do
      onboarded_spending
      onboarded_balances true
      onboarded_cards true
      ready false
    end

    trait :ready do
      onboarded
      after(:build) do |person|
        person.update_attribute(:ready, true)
      end
    end

    factory :companion,               traits: [:companion]
    factory :person_with_spending,    traits: [:onboarded_spending]
    factory :owner_with_spending,     traits: [:onboarded_spending, :main]
    factory :companion_with_spending, traits: [:onboarded_spending, :companion]
  end
end
