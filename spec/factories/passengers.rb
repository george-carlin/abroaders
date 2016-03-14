FactoryGirl.define do
  factory :passenger, aliases: [:main_passenger] do
    account
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name  }
    phone_number { Faker::PhoneNumber.phone_number }
    main true

    trait :companion do
      main false
    end

    trait :completed_card_survey do
      has_added_cards true
    end

    # trait :complete do
    #   has_added_cards    true
    #   has_added_balances true
    # end
  end
end
