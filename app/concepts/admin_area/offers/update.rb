module AdminArea
  module Offers
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :offer)
      step Contract::Persist()
    end
  end
end
