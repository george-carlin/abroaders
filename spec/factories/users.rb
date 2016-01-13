FactoryGirl.define do
  factory :user, aliases: [:confirmed_user] do
    sequence(:email) do |n|
      "#{Faker::Name.first_name.downcase}-#{rand(1000)}#{n}@example.com"
    end
    password               "abroaders123"
    password_confirmation  "abroaders123"
    confirmed_at           "2015-01-01"

    factory :admin do
      admin true
    end
  end
end
