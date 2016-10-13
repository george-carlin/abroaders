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

    trait :eligible do
      after(:build) { |acc| acc.people.each { |p| p.eligible = true } }
    end

    trait :onboarded_spending do
      eligible
      after(:build) do |acc|
        acc.people.each do |p|
          p.build_spending_info(attributes_for(:spending, person: nil))
        end
      end
    end

    trait :onboarded do
      onboarding_state :complete
    end

    trait :ready do
      onboarded
      after(:build) do |acc|
        acc.people.each do |person|
          person.update_attribute(:ready, true)
        end
      end
    end

    factory :onboarded_account, traits: [:onboarded]
    factory :onboarded_account_with_companion,
              traits: [:with_companion, :onboarded]
  end
end
