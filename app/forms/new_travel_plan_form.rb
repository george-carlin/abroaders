class NewTravelPlanForm < TravelPlanForm
  def show_skip_survey?
    !account.onboarded?
  end

  def initialize(*args)
    super
    self.no_of_passengers ||= 1
  end

  private

  def persist!
    plan = account.travel_plans.build(travel_plan_attributes)
    plan.flights.build(flight_attributes)
    plan.save!
    unless account.onboarded?
      new_state = OnboardingFlow.build(account).add_travel_plan!
      account.update!(onboarding_state: new_state)
    end
  end
end
