module AdminArea::Currencies
  # @!method self.call(params, options = {})
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :currency)
    step Contract::Persist()
  end
end
