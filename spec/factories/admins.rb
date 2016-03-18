FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin-#{rand(1000)}#{n}@example.com" }
    password               "abroaders123"
    password_confirmation  "abroaders123"
  end
end
