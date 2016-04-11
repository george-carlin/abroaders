FactoryGirl.define do
  factory :flight do
    from do
      if Destination.any?
        Destination.order("random()").first
      else
        create(:region)
      end
    end
    to do
      if Destination.any?
        Destination.order("random()").first
      else
        create(:region)
      end
    end
  end
end
