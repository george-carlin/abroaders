class HomeAirportsSurvey < ApplicationForm
  attribute :account, Account
  attribute :airport_ids, Array[Integer]

  validates :account, presence: true
  validates :airport_ids, presence: true, length: { minimum: 1, maximum: 5 }

  private

  def persist!
    account.home_airports << Airport.where(id: airport_ids)
    Account::Onboarder.new(account).add_home_airports!
  end
end
