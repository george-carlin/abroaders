FactoryGirl.define do
  factory :spending_info, aliases: [:spending] do
    person

    credit_score do
      min = SpendingInfo::MINIMUM_CREDIT_SCORE
      max = SpendingInfo::MAXIMUM_CREDIT_SCORE
      min + rand(max - min)
    end
  end
end
