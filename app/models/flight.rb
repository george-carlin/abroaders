class Flight < ApplicationRecord
  # Validations

  validates :position, uniqueness: { scope: :travel_plan_id }, null: false
  # (other validations for this model live in the form objects)

  # Associations

  belongs_to :travel_plan
  belongs_to :from, class_name: "Destination"
  belongs_to :to,   class_name: "Destination"
end
