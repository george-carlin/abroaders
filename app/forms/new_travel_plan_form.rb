class NewTravelPlanForm < TravelPlanForm
  private

  def persist!
    plan = account.travel_plans.build(travel_plan_attributes)
    plan.flights.build(flight_attributes)
    plan.save!

    unless account.onboarding_survey.complete?
      account.onboarding_survey.add_travel_plan!
    end
  end
end
