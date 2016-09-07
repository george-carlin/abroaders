class EditTravelPlanForm < TravelPlanForm
  attribute :id,      Integer
  attribute :from_id, Integer, default: lambda { |tp,_| tp.flight.from_id }
  attribute :to_id,   Integer, default: lambda { |tp,_| tp.flight.to_id }

  def self.find(id)
    new(::TravelPlan.find(id).attributes)
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

end
