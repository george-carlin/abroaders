FactoryGirl.define do
  factory :travel_plan do
    account
    no_of_passengers { rand(2) + 1 }
    acceptable_classes [:economy]

    type :single

    depart_on do
      rand(5).days.from_now
    end

    trait :single do
      type :single
    end

    trait :return do
      type :return

      return_on do
        (5 + rand(15)).days.from_now
      end
    end

    trait :multi do
      type :multi
    end

    after(:build) do |travel_plan, _|
      unless travel_plan.flights.any?
        travel_plan.flights << build(:flight, travel_plan: nil)
      end
    end
  end
end
