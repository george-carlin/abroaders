FactoryGirl.define do
  factory :bank do
    sequence(:name) { |n| "Bank #{n}" }
    personal_phone '555 1234 000'
    business_phone '555 2468 555'
  end
end
