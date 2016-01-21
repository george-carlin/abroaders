FactoryGirl.define do
  factory :card, aliases: [:active_card] do
    sequence(:identifier) { |n| "EXMPL-#{n}" }
    sequence(:name) { |n| "Example Card #{n}" }
    brand { Card.brands.keys.sample }
    bp    { Card.bps.keys.sample }
    type  { Card.types.keys.sample }
    bank  { Card.banks.keys.sample }
    annual_fee_cents { rand(500_00) + 10_00 }

    factory :inactive_card do
      active false
    end
  end
end
