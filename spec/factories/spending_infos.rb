FactoryGirl.define do
  factory :spending_info do
    passenger

    credit_score do
      min = SpendingInfo::MINIMUM_CREDIT_SCORE
      max = SpendingInfo::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
    personal_spending { rand(1000) + 9000 }

  end
end
