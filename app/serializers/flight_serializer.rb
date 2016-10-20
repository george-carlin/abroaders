class FlightSerializer < ApplicationSerializer
  attributes :id, :from, :to, :position

  belongs_to :from, class_name: "Destination"
  belongs_to :to,   class_name: "Destination"
end
