class TravelPlanLeg < ApplicationRecord

  # Validations

  validates :travel_plan, presence: false
  validates :origin, presence: false
  validates :destination, presence: false
  validates :earliest_departure, presence: false
  validates :latest_departure, presence: false
  validates :position, uniqueness: { scope: :travel_plan_id }, null: false

  # Associations

  belongs_to :travel_plan
  belongs_to :origin, class_name: "Airport"
  belongs_to :destination, class_name: "Airport"

end
