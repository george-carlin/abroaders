FactoryGirl.define do
  factory :card_account do
    factory :card_recommendation do
      recommended_at { Time.now }
      status :recommended
    end
  end
end
