FactoryGirl.define do
  factory :account do
    transient do
      with_person true
    end

    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"

    after(:build) do |account, evaluator|
      if evaluator.with_person
        account.people.build(first_name: Faker::Name.first_name)
      end
    end

    # Make sure you put this trait *before* the other traits
    # when calling the factory, or the later traits won't apply to
    # the companion.
    #
    # Good:
    #     create(:account, :with_companion, :onboarded)
    # Bad:
    #     create(:account, :onboarded, :with_companion)
    trait :with_companion do
      after(:build) do |acc|
        acc.people.build(first_name: Faker::Name.first_name, main: false)
      end
    end

    trait :onboarded_travel_plans do
      onboarded_travel_plans true
    end

    trait :onboarded_type do
      # You can't select your account type until you've added a travel plan:
      onboarded_travel_plans
      onboarded_type true
    end

    trait :onboarded_spending do
      # You can't add your spending info until you've picked an account type:
      onboarded_type
      after(:build) do |acc|
        acc.people.each do |p|
          p.build_spending_info(attributes_for(:spending, person: nil))
        end
      end
    end

    trait :onboarded do
      onboarded_spending
      after(:build) do |acc|
        acc.people.each do |p|
          p.onboarded_cards = p.onboarded_balances = true
          p.build_readiness_status(ready: true)
        end
      end
    end

    factory :onboarded_account, traits: [:onboarded]
    factory :onboarded_account_with_companion,
              traits: [:with_companion, :onboarded]
  end
end
