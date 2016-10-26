class FlightSerializer < ApplicationSerializer
  attributes :id, :from, :to, :position

  belongs_to :from, serializer: DestinationSerializer
  belongs_to :to,   serializer: DestinationSerializer
end
