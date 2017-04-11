class TravelPlan < TravelPlan.superclass
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :travel_plan)
    step Contract::Persist()
  end
end
