FactoryGirl.define do
  factory :card_account do
    person
    status :unknown
    card
    source :from_survey

    trait :open do
      status :open
      opened_at { 2.years.ago }
    end

    trait :closed do
      open
      status :closed
      closed_at { 1.year.ago }
    end

    trait :clicked do
      clicked_at { 3.days.ago }
    end

    trait :survey do
      open
      source :from_survey
    end

    trait :recommendation do
      status :recommended
      recommended_at { Time.now }
      card nil
      offer
      source :recommendation
    end

    trait :declined do
      recommendation
      status :declined
      applied_at { Time.now }
      decline_reason "You suck!"
    end

    factory :survey_card_account, traits: [:survey]
    factory :open_survey_card_account, traits: [:survey, :open]
    # The order of the traits is important here:
    factory :closed_survey_card_account, traits: [:survey, :closed]

    factory :card_recommendation, traits: [:recommendation]
    factory :clicked_card_recommendation, traits: [:recommendation, :clicked]
    factory :declined_card_recommendation, traits: [:recommendation, :declined]
  end
end
