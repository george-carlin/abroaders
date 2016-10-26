class AccountSerializer < ApplicationSerializer
  attributes :id, :email, :phone_number, :monthly_spending_usd, :created_at, :balances_by_currencies

  has_one :owner
  has_one :companion
  has_one :home_airports
  has_many :travel_plans
  has_many :regions_of_interest
  has_many :recommendation_notes

  always_include :owner
  always_include :companion
  always_include :home_airports
  always_include :travel_plans
  always_include :regions_of_interest
  always_include :recommendation_notes

  def balances_by_currencies
    object.balances.group_by(&:currency).to_a
  end
end
