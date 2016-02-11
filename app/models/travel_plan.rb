class TravelPlan < ApplicationRecord

  # Attributes

  TYPES = %i[single return multi]
  enum types: TYPES
  DEFAULT_TYPE = :return
  MAX_NUMBER_OF_LEGS       = 20
  MAX_NUMBER_OF_PASSENGERS = 20

  # Validations

  validates :no_of_passengers,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    MAX_NUMBER_OF_PASSENGERS,
    }

  # Associations

  belongs_to :user
  has_many :legs, class_name: "TravelLeg"

  accepts_nested_attributes_for :legs

end
