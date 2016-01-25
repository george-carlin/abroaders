FactoryGirl.define do
  factory :card_account, aliases: [:card_recommendation, :card_rec] do
    recommended_at { Time.now }
    status :recommended
    card
    user

    factory :declined_card_recommendation do
      status :declined
      declined_at { Time.now }
    end
  end
end
