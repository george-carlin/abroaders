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

    trait :survey do
      open
      source :from_survey
    end

    factory :card_recommendation, aliases: [:card_rec] do
      status :recommended
      recommended_at { Time.now }
      card nil
      offer
      source :recommendation

      factory :declined_card_recommendation do
        status :declined
        declined_at { Time.now }
        decline_reason "You suck!"
      end
    end

    factory :open_survey_card_account, traits: [:survey]
    # The order of the traits is important here:
    factory :closed_survey_card_account, traits: [:survey, :closed]
  end
end
