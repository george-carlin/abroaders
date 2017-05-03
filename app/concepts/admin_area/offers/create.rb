module AdminArea
  module Offers
    class Create < Trailblazer::Operation
      step Nested(New)
      step Contract::Validate(key: :offer)
      step Contract::Persist()
    end
  end
end
