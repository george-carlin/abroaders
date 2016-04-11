FactoryGirl.define do
  factory :flight do
    from { Destination.order("random()").first }
    to   { Destination.order("random()").first }
  end
end
