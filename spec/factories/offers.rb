FactoryGirl.define do
  factory :offer, aliases: [:live_offer] do
    card
    condition "on_minimum_spend"
    points_awarded { rand(20) * 5_000 }
    spend { rand(10) * 500 }
    cost { rand(20) * 5 }
    days { [30, 60, 90, 90, 90, 90, 90, 90, 120].sample }
    link { Faker::Internet.url("example.com") }
    partner "card_benefit"

    factory :dead_offer do
      killed_at { Time.zone.now - (rand * 21) }
    end
  end
end
