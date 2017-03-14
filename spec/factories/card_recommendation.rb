FactoryGirl.define do
  factory :card_recommendation, aliases: [:card_rec], class: Card do
    person
    recommended_at { Time.zone.now }
    product nil
    offer { create_offer }

    trait :applied do
      applied_at { 4.days.ago }
    end

    trait :approved do
      applied
      opened_on { Date.today }
    end

    trait :called do
      denied
      called_at { Time.zone.now }
    end

    trait :clicked do
      clicked_at { Time.zone.now }
    end

    trait :declined do
      declined_at { Time.zone.now }
      decline_reason "You suck!"
    end

    trait :denied do
      applied
      denied_at { 3.days.ago }
    end

    trait :expired do
      expired_at { Time.zone.now }
    end

    trait :nudged do
      applied
      nudged_at { Time.zone.now }
    end

    trait :redenied do
      called
      redenied_at { Time.zone.now }
    end

    trait :seen do
      seen_at { 1.year.ago }
    end

    trait :pulled do
      pulled_at { Time.zone.now }
    end
  end
end
