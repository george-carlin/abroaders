class TravelPlan < ApplicationRecord

  # Attributes

  TYPES = %i[single return multi]
  DEFAULT_TYPE = :return
  MAX_NUMBER_OF_LEGS = 20

  # Validations

  # Associations

  belongs_to :user
  has_many :legs, class_name: "TravelLeg"

end
