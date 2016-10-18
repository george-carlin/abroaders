FactoryGirl.define do
  factory :flight do
    from { create(:airport) }
    to { create(:airport) }
  end
end
