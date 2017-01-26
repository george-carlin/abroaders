class TravelPlan < ApplicationRecord
  module Operations
    class Create < Trailblazer::Operation
      step Nested(Operations::New)
      step Contract::Validate(key: :travel_plan)
      step Contract::Persist()
    end
  end
end
