FactoryGirl.define do
  factory :currency do
    sequence(:name) { |n| "Currency #{n}" }
    sequence(:award_wallet_id) { |n| "currency #{n}" }
    sequence(:alliance_name) { |n| %w[OneWorld StarAlliance SkyTeam Independent][n % 4] }
    shown_on_survey true
    type "airline"
  end
end
