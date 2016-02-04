FactoryGirl.define do
  factory :card_offer, aliases: [:live_card_offer] do
    card
    sequence(:identifier) do |n|
      letters = ('A'..'Z').to_a.shuffle.first(4).join
      "%02d-#{letters}" % n
    end
    points_awarded { rand(20) * 5_000 }
    spend { rand(10) * 500 }
    cost { rand(20) * 5 }
    days { [30, 60, 90, 90, 90, 90, 90, 90, 120].sample }

    factory :expired_card_offer do
      status :expired
    end
  end
end
