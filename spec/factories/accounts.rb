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
    #     create(:account, :couples, :eligible)
    # Bad:
    #     create(:account, :eligible, :couples)
    trait :couples do
      onboarding_state :eligibility # if they have a companion they must be at least here
      after(:build) do |acc|
        acc.people.build(first_name: Faker::Name.first_name, owner: false)
      end
    end

    trait :eligible do
      onboarding_state :owner_cards # if they're eligible they must be at least here
      after(:build) { |acc| acc.people.each { |p| p.eligible = true } }
    end

    trait :onboarded do
      onboarding_state :complete
    end

    factory :couples_account,           traits: [:couples]
    factory :onboarded_account,         traits: [:onboarded]
    factory :onboarded_couples_account, traits: [:couples, :onboarded]
  end
end
