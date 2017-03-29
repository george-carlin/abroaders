FactoryGirl.define do
  # TODO this should be replaced with Card::Operations::Create
  factory :card do
    person
    association(:product, factory: :card_product)

    opened_on { 2.years.ago }

    trait :closed do
      open
      closed_on { 1.year.ago }
    end
  end
end
