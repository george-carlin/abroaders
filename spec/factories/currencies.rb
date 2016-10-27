FactoryGirl.define do
  factory :currency do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:award_wallet_id) { |n| "currency #{n}" }
    alliance
    shown_on_survey true
    type "airline"
  end
end
