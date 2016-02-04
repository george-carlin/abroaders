class TravelPlan < ApplicationRecord

  # Attributes

  TYPES = %i[single return multi]
  enum types: TYPES
  DEFAULT_TYPE = :return
  MAX_NUMBER_OF_LEGS = 20

  # Validations

  # Associations

  belongs_to :user
  has_many :legs, class_name: "TravelLeg"

  accepts_nested_attributes_for :legs

end
