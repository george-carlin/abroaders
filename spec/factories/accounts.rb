FactoryGirl.define do
  factory :account do
    transient do
      # Don't use this attribute directly. It's used by the person factory so
      # that when you call create(:person) only 1 person is created.
      with_person true
    end

    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"

    after(:build) do |account, evaluator|
      account.people.build(first_name: 'Erik') if evaluator.with_person
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
      after(:build) do |acc|
        acc.people.build(first_name: 'Gabi', owner: false)
      end
    end

    trait :eligible do
      after(:build) { |acc| acc.people.each { |p| p.eligible = true } }
    end

    # If you're using this trait in conjunction with :couples or :eligible,
    # make sure that it's the LAST trait in the list of args.
    trait :onboarded do
      onboarding_state :complete
    end
  end
end
