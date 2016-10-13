class NewTravelPlanForm < TravelPlanForm
  def show_skip_survey?
    account.onboarding_survey.incomplete?
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

    unless account.onboarding_survey.complete?
      account.onboarding_survey.add_travel_plan!
    end
  end
end
