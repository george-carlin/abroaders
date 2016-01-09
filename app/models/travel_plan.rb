class TravelPlan < ApplicationRecord

  # Validations

  # Associations

  belongs_to :user
  has_many :travel_plan_legs

end
