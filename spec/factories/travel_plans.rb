FactoryGirl.define do
  factory :travel_plan do
    user
    no_of_passengers { rand(2) + 1 }
    departure_date_range do
      earliest = rand(5)
      latest   = earliest + rand(15)
      earliest.days.from_now..latest.days.from_now
    end

    trait :single do
      type :single
      after(:build) do |plan|
        plan.flights.build(attributes_for(:flight, travel_plan: nil))
      end
    end

    trait :return do
      type :return
      after(:build) do |plan|
        plan.flights.build(attributes_for(:flight, travel_plan: nil))
      end
    end

    trait :multi do
      type :multi
      after(:build) do |plan|
        (rand(3)+2).times do |i|
          plan.flights.build(
            attributes_for(:flight, travel_plan: nil, position: i)
          )
        end
      end
    end
  end
end
