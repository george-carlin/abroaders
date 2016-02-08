FactoryGirl.define do
  factory :card_account do
    status :unknown
    card

    factory :card_recommendation, aliases: [:card_rec] do
      status :recommended
      recommended_at { Time.now }
      card nil
      offer

      factory :declined_card_recommendation do
        status :declined
        declined_at { Time.now }
      end
    end
  end
end
