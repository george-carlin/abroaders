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

    trait :onboarded_balances do
      onboarded_balances true
    end

    trait :onboarded do
      onboarded_spending
      onboarded_balances
      onboarded_cards
      ready false
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
