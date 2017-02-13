FactoryGirl.define do
  factory :card do
    person
    association(:product, factory: :card_product)

    trait :open do
      opened_at { 2.years.ago }
    end

    trait :closed do
      open
      closed_at { 1.year.ago }
    end
  end
end
