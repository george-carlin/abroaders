class HomeAirportsSurvey < ApplicationForm
  attribute :account, Account
  attribute :airport_ids, Array[Integer]

  validates :account, presence: true
  validates :airport_ids, presence: true, length: { minimum: 1, maximum: 5 }

  # def self.name
  #   "HomeAirports"
  # end

  private

  def persist!
    account.home_airports << Airport.where(id: airport_ids)
    account.onboarded_home_airports = true
    account.save!
  end
end
