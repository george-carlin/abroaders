FactoryGirl.define do
  factory :spending_info, aliases: [:spending] do
    person

    has_business 'no_business'

    credit_score do
      min = CreditScore.min
      max = CreditScore.max
      min + rand(max - min)
    end
  end
end
