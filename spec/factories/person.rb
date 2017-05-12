FactoryGirl.define do
  factory :person, aliases: [:owner] do
    association(:account, factory: :account, with_person: false)
    first_name 'Erik'

    trait :eligible do
      eligible true
    end

    owner true

    trait :companion do
      first_name 'Gabi'
      owner false
    end

    factory :companion, traits: [:companion]
  end
end
