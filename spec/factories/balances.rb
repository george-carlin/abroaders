FactoryGirl.define do
  factory :balance do
    person
    currency
    value 1
  end
end
