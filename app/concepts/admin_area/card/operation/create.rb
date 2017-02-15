module AdminArea
  module Card
    module Operation
      class Create < Trailblazer::Operation
        step Nested(New)
        step Contract::Validate(key: :card)
        step Contract::Persist()
      end
    end
  end
end
