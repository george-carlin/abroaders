module AdminArea
  module CardRecommendations
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :card)
      step Contract::Persist()
    end
  end
end
