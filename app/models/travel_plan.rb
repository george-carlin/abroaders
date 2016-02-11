class TravelPlan < ApplicationRecord

  # Attributes

  TYPES = %i[single return multi]
  enum types: TYPES

  DEFAULT_TYPE   = :return
  MAX_FLIGHTS    = 20
  MAX_PASSENGERS = 20

  # Validations

  validates :no_of_passengers,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    MAX_PASSENGERS,
    }

  # Associations

  belongs_to :user
  has_many :flights

  accepts_nested_attributes_for :flights

end
