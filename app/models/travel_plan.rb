class TravelPlan < ApplicationRecord

  # Associations

  belongs_to :user
  has_many :travel_plan_legs

end
