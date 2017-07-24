module AdminArea::Currencies
  # @!method self.call(params, options = {})
  class Update < Trailblazer::Operation
    step Nested(Edit)
    step Contract::Validate(key: :currency)
    step Contract::Persist()
  end
end
