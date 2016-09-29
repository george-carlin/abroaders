class SpendingInfoSerializer < ApplicationSerializer
  attributes :id, :credit_score, :will_apply_for_loan,
    :business_spending_usd, :has_business
end
