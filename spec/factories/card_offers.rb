FactoryGirl.define do
  factory :card_offer, aliases: [:offer, :live_card_offer] do
    card
    points_awarded { rand(20) * 5_000 }
    spend { rand(10) * 500 }
    cost { rand(20) * 5 }
    days { [30, 60, 90, 90, 90, 90, 90, 90, 120].sample }
    link "http://example.com"

    factory :expired_card_offer do
      status :expired
    end
  end
end
