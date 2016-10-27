FactoryGirl.define do
  factory :bank do
    name { |n| "Bank #{n}" }
    personal_phone "000-000"
    business_phone "000-000"
  end
end
