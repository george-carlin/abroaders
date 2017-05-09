FactoryGirl.define do
  factory :person, aliases: [:owner] do
    association(:account, factory: :account, with_person: false)
    first_name 'Erik'

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
      first_name 'Gabi'
      owner false
    end

    factory :companion, traits: [:companion]
  end
end
