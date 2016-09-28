class AccountSerializer < ApplicationSerializer
  attributes :email, :phone_number, :monthly_spending_usd,
             :created_at

  has_many :people

  class PersonSerializer < ApplicationSerializer
    attributes :first_name, :ready, :eligible, :main

    has_one :spending_info

    class SpendingInfoSerializer < ApplicationSerializer
      attributes :credit_score, :will_apply_for_loan,
                 :business_spending_usd, :has_business
    end
  end
end
