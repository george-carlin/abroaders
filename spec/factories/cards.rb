FactoryGirl.define do
  factory :card do
    sequence(:identifier) { |n| "EXMPL-#{n}" }
    sequence(:name) { |n| "Example Card #{n}" }
    brand { Card.brands.keys.sample }
    bp    { Card.bps.keys.sample }
    type  { Card.types.keys.sample }
    bank  { Card.banks.keys.sample }
    annual_fee_cents { rand(500_00) + 10_00 }
  end
end
