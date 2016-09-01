class NewTravelPlanForm < TravelPlanForm

  def persist!
    plan = account.travel_plans.build(travel_plan_attributes)
    plan.flights.build(flight_attributes)
    plan.save!
    unless @account.onboarded_travel_plans?
      @account.update_attributes!(onboarded_travel_plans: true)
    end
  end

end
