FactoryGirl.define do
  factory :recommendation_note do
    content { Faker::Lorem.sentence }
  end
end
