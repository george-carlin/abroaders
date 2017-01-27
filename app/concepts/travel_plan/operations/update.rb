class TravelPlan < ApplicationRecord
  module Operations
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :travel_plan)
      # failure -> (opts) { debugger; puts }
      step Contract::Persist()
      # failure -> (opts) { debugger; puts }
    end
  end
end
