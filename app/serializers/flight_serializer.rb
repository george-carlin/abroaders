class FlightSerializer < ApplicationSerializer
  attributes :id, :from, :to, :position

  def from
    destination_name(object.from)
  end

  def to
    destination_name(object.to)
  end

  private

  def destination_name(destination)
    if destination.region?
      destination.region.name
    else
      "#{destination.name} (#{destination.code})"
    end
  end
end
