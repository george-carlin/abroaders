FactoryGirl.define do
  factory :card_account do
    person
    status :unknown
    card
    source :from_survey

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
  end
end
