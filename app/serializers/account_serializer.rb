class AccountSerializer < ApplicationSerializer
  attributes :id, :email, :phone_number, :monthly_spending_usd, :created_at

  has_one :owner
  has_one :companion

  always_include :owner
  always_include :companion
end
