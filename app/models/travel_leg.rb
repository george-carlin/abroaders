class TravelLeg < ApplicationRecord

  # Validations

  validates :travel_plan, presence: false
  validates :from, presence: false
  validates :to, presence: false
  validates :date, presence: false
  validates :position, uniqueness: { scope: :travel_plan_id }, null: false

  # Associations

  belongs_to :travel_plan
  belongs_to :from, class_name: "Destination"
  belongs_to :to,   class_name: "Destination"

end
