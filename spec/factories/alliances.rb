FactoryGirl.define do
  factory :alliance do
    sequence(:name) { |n| %w[OneWorld StarAlliance SkyTeam Independent][n % 4] }
    sequence(:order) { |n| n }
  end
end
