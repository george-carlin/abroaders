class EditTravelPlanForm < TravelPlanForm
  attribute :id,      Integer
  attribute :from_id, Integer, default: lambda { |tp, _| tp.flight.from_id }
  attribute :to_id,   Integer, default: lambda { |tp, _| tp.flight.to_id }

  def self.find(id)
    travel_plan = ::TravelPlan.find(id)
    new_attributes = {
      departure_date: travel_plan.depart_on,
      return_date: travel_plan.return_on,
      will_accept_economy: travel_plan.will_accept_economy?,
      will_accept_premium_economy: travel_plan.will_accept_premium_economy?,
      will_accept_business_class: travel_plan.will_accept_business_class?,
      will_accept_first_class: travel_plan.will_accept_first_class?
    }
    new(travel_plan.attributes.merge(new_attributes))
  end

  def from_name
    displayed_name(Destination.find(from_id))
  end

  def to_name
    displayed_name(Destination.find(to_id))
  end

  def persisted?
    true
  end

  def flight
    @flight ||= travel_plan.flights.first
  end

  private

  def persist!
    flight.update_attributes!(flight_attributes)
    travel_plan.update_attributes!(travel_plan_attributes)
  end

  def travel_plan
    @travel_plan ||= TravelPlan.find(id)
  end

  def displayed_name(destination)
    "#{destination.name} (#{destination.code})"
  end
end
