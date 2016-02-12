FactoryGirl.define do
  factory :flight do
    # Right now this factory doesn't work if you call it directly, it only
    # works when called from the parent travel_plan factory :/
    from { Destination.order("random()").first }
    to   { Destination.order("random()").first }
  end
end
