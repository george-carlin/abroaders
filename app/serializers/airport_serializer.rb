class AirportSerializer < ApplicationSerializer
  attributes :id, :full_name

  def full_name
    "#{object.parent.name} (#{object.code})"
  end
end
