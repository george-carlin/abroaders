FactoryGirl.define do
  factory :card do
    person
    association(:product, factory: :card_product)

    trait :open do
      opened_at { 2.years.ago }
    end

    trait :closed do
      open
      closed_at { 1.year.ago }
    end

    trait :seen do
      seen_at { 1.year.ago }
    end

    trait :clicked do
      seen
      clicked_at { 3.days.ago }
    end

    trait :applied do
      recommendation
      applied_at { 4.days.ago }
    end

    trait :denied do
      applied
      denied_at { 3.days.ago }
    end

    trait :recommendation do
      recommended_at { Time.now }
      product nil
      offer
    end

    trait :declined do
      recommendation
      declined_at { Time.zone.now }
      decline_reason "You suck!"
    end

    trait :expired do
      recommendation
      expired_at { Time.zone.now }
    end

    trait :called do
      denied
      called_at { Time.zone.now }
    end

    trait :redenied do
      called
      redenied_at { Time.zone.now }
    end

    trait :nudged do
      applied
      nudged_at { Time.zone.now }
    end

    trait :pulled do
      recommendation
      pulled_at { Time.zone.now }
    end

    factory :card_recommendation, traits: [:recommendation], aliases: [:card_rec]
    factory :clicked_card_recommendation, traits: [:recommendation, :clicked]
    factory :declined_card_recommendation, traits: [:recommendation, :declined]

    factory :denied_card_recommendation, traits: [:denied]
  end
end
