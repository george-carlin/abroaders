FactoryGirl.define do
  factory :destination do
    name do
      raise "don't call 'destination' factory directly, use one of the "\
            "sub-factories"
    end

    factory :region do
      type :region
      sequence(:name) { |n| "Region #{n}" }
      sequence(:code) do |n|
        str = "AA"
        (n-1).times { |i| str.next! }
        str
      end
    end

    factory :country do
      type :country

      sequence(:name) { |n| "Country #{n}" }
      sequence(:code) do |n|
        str = "AA"
        (n-1).times { |i| str.next! }
        str
      end
    end

    factory :airport do
      type :airport
      name { Faker::Address.city }
      sequence(:code) do |n|
        str = "AA"
        (n-1).times { |i| str.next! }
        str
      end
      association :parent, factory: :region
    end
  end
end
