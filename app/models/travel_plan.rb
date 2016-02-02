class TravelPlan < ApplicationRecord

  # Attributes

  DEFAULT_TYPE = :return

  # Validations

  # Associations

  belongs_to :user
  has_many :travel_plan_legs

end
