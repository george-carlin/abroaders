FactoryGirl.define do
  factory :card_account do
    person
    card

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

    trait :survey do
      open
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
      card nil
      offer
    end

    trait :declined do
      recommendation
      declined_at { Time.now }
      decline_reason "You suck!"
    end

    trait :expired do
      recommendation
      expired_at { Time.now }
    end

    trait :called do
      denied
      called_at { Time.now }
    end

    trait :redenied do
      called
      redenied_at { Time.now }
    end

    trait :nudged do
      applied
      nudged_at { Time.now }
    end

    factory :survey_card_account, traits: [:survey]
    factory :open_survey_card_account, traits: [:survey, :open]
    # The order of the traits is important here:
    factory :closed_survey_card_account, traits: [:survey, :closed]

    factory :card_recommendation, traits: [:recommendation]
    factory :clicked_card_recommendation, traits: [:recommendation, :clicked]
    factory :declined_card_recommendation, traits: [:recommendation, :declined]

    factory :denied_card_recommendation, traits: [:denied]
  end
end
