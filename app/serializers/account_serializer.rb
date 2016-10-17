class AccountSerializer < ApplicationSerializer
  attributes :id, :email, :phone_number, :monthly_spending_usd, :created_at, :balances_by_currencies

  has_one :owner
  has_one :companion
  has_one :home_airports

  always_include :owner
  always_include :companion
  always_include :home_airports

  def balances_by_currencies
    object.balances.group_by(&:currency).to_a
  end
end
