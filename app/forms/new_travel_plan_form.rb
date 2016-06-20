class NewTravelPlanForm < TravelPlanForm

  def persist!
    plan = account.travel_plans.build(travel_plan_attributes)
    plan.flights.build(flight_attributes)
    plan.save!
    unless @account.onboarded_travel_plans?
      @account.update_attributes!(onboarded_travel_plans: true)
      IntercomJobs::TrackEvent.perform_later(
        email: @account.email,
        event_name: "onboarded_travel_plan",
      )
    end
  end

end
