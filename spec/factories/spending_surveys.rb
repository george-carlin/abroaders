FactoryGirl.define do
  factory :spending_survey do
    passenger

    credit_score do
      min = SpendingSurvey::MINIMUM_CREDIT_SCORE
      max = SpendingSurvey::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
    personal_spending { rand(1000) + 9000 }

  end
end
