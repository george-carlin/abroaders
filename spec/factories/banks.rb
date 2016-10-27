FactoryGirl.define do
  factory :bank do
    sequence(:name) { |n| "Bank #{n}" }
    personal_code  { ((rand(7) + 1) * 2) - 1 } # must be an odd, positive number
    personal_phone '555 1234 000'
    business_phone '555 2468 555'
  end
end
