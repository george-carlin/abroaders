FactoryGirl.define do
  factory :bank do
    name { |n| "Bank #{n}" }
    personal_phone "000-000"
    business_phone "111-111"
  end
end
