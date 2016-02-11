class TravelPlan < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  TYPES = %i[single return multi]
  enum type: TYPES

  DEFAULT_TYPE   = :return
  MAX_FLIGHTS    = 20
  MAX_PASSENGERS = 20

  # Validations

  validates :no_of_passengers,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    MAX_PASSENGERS,
    }

  validate :number_of_flights_matches_type

  # Associations

  belongs_to :user
  has_many :flights

  accepts_nested_attributes_for :flights

  private

  def number_of_flights_matches_type
    if (!multi? && flights.size != 1) || (multi? && flights.size <= 1)
      errors.add(:base, t("activerecord.errors.travel_plan.bad_flight_count"))
    end
  end

end
