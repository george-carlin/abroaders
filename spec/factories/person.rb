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

    trait :companion do
      main false
    end

    trait :onboarded do
      onboarding_state "complete"
    end

    trait :ready do
      onboarded
      ready true
    end

    factory :companion, traits: [:companion]
  end
end
