class NewTravelPlanForm < TravelPlanForm

  def initialize(account)
    @account = account
    @no_of_passengers = 1
    @type = "return"
    @will_accept_economy         = false
    @will_accept_premium_economy = false
    @will_accept_business_class  = false
    @will_accept_first_class     = false
    @earliest_departure = Date.today.strftime("%m/%d/%Y")
  end

  def save
    super do
      plan = @account.travel_plans.build
      plan.type = type
      plan.flights.build
      plan.flights.first.from   = Destination.country.find(from_id)
      plan.flights.first.to     = Destination.country.find(to_id)
      plan.departure_date_range = earliest_departure..earliest_departure
      plan.further_information  = further_information.strip
      plan.no_of_passengers     = no_of_passengers
      acceptable_classes = []
      acceptable_classes << :economy         if will_accept_economy?
      acceptable_classes << :premium_economy if will_accept_premium_economy?
      acceptable_classes << :business_class  if will_accept_business_class?
      acceptable_classes << :first_class     if will_accept_first_class?
      plan.acceptable_classes = acceptable_classes
      plan.save!
    end
  end
end
