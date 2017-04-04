class TravelPlan < TravelPlan.superclass
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Operation::New)
      step Contract::Validate(key: :travel_plan)
      step Contract::Persist()
    end
  end
end
