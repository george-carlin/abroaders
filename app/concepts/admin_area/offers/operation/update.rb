module AdminArea
  module Offers
    module Operation
      class Update < Trailblazer::Operation
        step Nested(Edit)
        step Contract::Validate(key: :offer)
        step Contract::Persist()
      end
    end
  end
end
