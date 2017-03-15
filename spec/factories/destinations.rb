FactoryGirl.define do
  factory :destination do
    name do
      raise "don't call 'destination' factory directly, use one of the "\
            "sub-factories"
    end
  end

  trait :two_letter_code do
    sequence(:code) do |n|
      str = "AA"
      (n - 1).times { str.next! }
      str
    end
  end

  trait :three_letter_code do
    sequence(:code) do |n|
      str = "AAA"
      (n - 1).times { str.next! }
      str
    end
  end

  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    two_letter_code
    sequence(:region_code) { |n| Region.codes[n % Region.codes.length] }
  end

  factory :city do
    sequence(:name) { |n| "City #{n}" }
    two_letter_code
    association :parent, factory: :country
  end

  factory :airport do
    name { Faker::Address.city }
    three_letter_code
    association :parent, factory: :city
  end
end
