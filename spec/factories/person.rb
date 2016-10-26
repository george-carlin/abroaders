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

    owner true

    trait :owner do
      owner true
    end

    trait :companion do
      owner false
    end

    trait :onboarded do
      onboarding_state "complete"
    end

    trait :ready do
      onboarded
      ready true
    end

    factory :companion,               traits: [:companion]
    factory :person_with_spending,    traits: [:onboarded_spending]
    factory :owner_with_spending,     traits: [:onboarded_spending, :owner]
    factory :companion_with_spending, traits: [:onboarded_spending, :companion]
  end
end
