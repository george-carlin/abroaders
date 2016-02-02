FactoryGirl.define do
  factory :card, aliases: [:active_card] do
    sequence(:identifier) { |n| "EXMPL-#{n}" }
    sequence(:name) { |n| "Example Card #{n}" }
    brand { Card.brands.keys.sample }
    bp    { Card.bps.keys.sample }
    type  { Card.types.keys.sample }
    bank  { Card.banks.keys.sample }
    annual_fee_cents { rand(500_00) + 10_00 }

    currency_id { Currency.valid_ids.sample }

    factory :inactive_card do
      active false
    end

    trait :business do
      bp :business
    end

    trait :personal do
      bp :personal
    end
  end
end
