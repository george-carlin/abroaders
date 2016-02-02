FactoryGirl.define do
  factory :destination do
    name do
      raise "don't call 'destination' factory directly, use one of the "\
            "sub-factories"
    end

    factory :airport do
      type :airport
      name { Faker::Address.city }
      sequence(:code) do |n|
        n.times do |i|
          str = "AAA"
          i.times { str.next! }
          str
        end
      end
    end
  end
end
