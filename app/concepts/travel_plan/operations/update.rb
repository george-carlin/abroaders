class TravelPlan < ApplicationRecord
  module Operations
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :travel_plan)
      step Contract::Persist()
    end
  end
end
