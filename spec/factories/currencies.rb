FactoryGirl.define do
  factory :currency do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:award_wallet_id) { |n| "currency #{n}" }
    shown_on_survey true
  end
end
