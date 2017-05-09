module AdminArea
  module CardRecommendations
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :card_recommendation)
      step Contract::Persist()
    end
  end
end
