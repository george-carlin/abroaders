FactoryGirl.define do
  factory :card, aliases: [:active_card] do
    sequence(:code) { |n| str = "AAA"; n.times { str.next! }; str }
    sequence(:name) { |n| "Example Card #{n}" }
    network { Card.networks.keys.sample }
    bp      { Card.bps.keys.sample }
    type    { Card.types.keys.sample }
    bank_id { Bank.all.sample.id }
    annual_fee_cents { rand(500_00) + 10_00 }
    image_name "placeholder-factory-this-sucks-change-me.png"

    currency { Currency.all.sample || create(:currency) }

    factory :inactive_card do
      active false
    end

    trait :business do
      bp :business
    end

    trait :personal do
      bp :personal
    end

    trait :chase do
      bank :chase
    end

    trait :us_bank do
      bank :us_bank
    end
  end
end
