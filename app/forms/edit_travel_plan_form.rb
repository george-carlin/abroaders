class EditTravelPlanForm < TravelPlanForm

  def initialize(travel_plan)
    @travel_plan      = travel_plan
    @no_of_passengers = @travel_plan.no_of_passengers
    @type    = @travel_plan.type
    @from_id = @travel_plan.flights.first.from_id
    @to_id   = @travel_plan.flights.first.to_id
    @will_accept_economy         = @travel_plan.will_accept_economy?
    @will_accept_premium_economy = @travel_plan.will_accept_premium_economy?
    @will_accept_business_class  = @travel_plan.will_accept_business_class?
    @will_accept_first_class     = @travel_plan.will_accept_first_class?
    @earliest_departure = @travel_plan.departure_date_range.first.strftime("%m/%d/%Y")
    @further_information = @travel_plan.further_information
  end

  def to_param
    @travel_plan.id.to_s
  end

  def persisted?
    true
  end

  private

  def persist!
    flight = @travel_plan.flights.first
    flight.from = Destination.country.find(from_id)
    flight.to   = Destination.country.find(to_id)
    flight.save!
    @travel_plan.type = type
    @travel_plan.departure_date_range = earliest_departure..earliest_departure
    @travel_plan.further_information  = further_information.strip
    @travel_plan.no_of_passengers     = no_of_passengers
    acceptable_classes = []
    acceptable_classes << :economy         if will_accept_economy?
    acceptable_classes << :premium_economy if will_accept_premium_economy?
    acceptable_classes << :business_class  if will_accept_business_class?
    acceptable_classes << :first_class     if will_accept_first_class?
    @travel_plan.acceptable_classes = acceptable_classes
    @travel_plan.save!
  end

end
