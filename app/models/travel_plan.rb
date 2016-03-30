class TravelPlan < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  TYPES = %i[single return multi]
  enum type: TYPES

  DEFAULT_TYPE   = :return
  MAX_FLIGHTS    = 20
  MAX_PASSENGERS = 20

  concerning :AcceptableClasses do
    # Warning: NEVER edit this array except to append new values to the end,
    # or you'll mess up all the existing data in the DB.
    # See https://github.com/joelmoss/bitmask_attributes
    CLASSES = %i[economy premium_economy business_class first_class]

    included do
      bitmask :acceptable_classes, as:  CLASSES
    end

    CLASSES.each do |klass|
      define_method :"will_accept_#{klass}?" do
        acceptable_classes.include?(klass)
      end
    end
  end

  def earliest_departure
    departure_date_range.first
  end

  def latest_departure
    departure_date_range.last
  end

  # Validations

  validates :departure_date_range, presence: true
  validates :no_of_passengers,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    MAX_PASSENGERS,
    }
  validates :type, presence: true
  validates :account, presence: true

  validate :number_of_flights_matches_type

  # Associations

  belongs_to :account
  has_many :flights, -> { order("position ASC") }

  accepts_nested_attributes_for :flights

  private

  def number_of_flights_matches_type
    if (!multi? && flights.size != 1) || (multi? && flights.size <= 1)
      errors.add(:base, :bad_flight_count)
    end
  end

end
