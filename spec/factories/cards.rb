FactoryGirl.define do
  factory :card do
    person
    association(:product, factory: :card_product)

    trait :open do
      opened_on { 2.years.ago }
    end

    trait :closed do
      open
      closed_on { 1.year.ago }
    end
  end
end
