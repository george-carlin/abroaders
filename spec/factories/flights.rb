FactoryGirl.define do
  factory :flight do
    travel_plan nil
    origin nil
    destination nil
    earliest_departure "2016-01-09"
    latest_departure "2016-01-09"
  end
end
