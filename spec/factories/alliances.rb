FactoryGirl.define do
  factory :alliance do
    sequence(:name) { |n| %w[OneWorld StarAlliance SkyTeam][n % 3] }
  end
end
