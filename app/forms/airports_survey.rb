class AirportsSurvey < ApplicationForm
  attribute :account, Account
  attribute :home_airports, Array[Airport]

  validates :account, presence: true
  validates :home_airports, length: { minimum: 1, maximum: 5, message: "are invalid" }

  def initialize(attributes={})
    home_airports = Airport.where(id: attributes[:home_airports_ids])
    attributes.merge!(home_airports: home_airports)
    super(attributes.except(:home_airports_ids))
  end

  def self.name
    "Home Airports"
  end

  private

  def persist!
    account.home_airports << home_airports
    account.onboarded_home_airports = true
    account.save!
  end
end
