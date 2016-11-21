FactoryGirl.define do
  factory :phone_number do
    account
    number '555 123-1234'
    normalized_number '555 123-1234'
  end
end
