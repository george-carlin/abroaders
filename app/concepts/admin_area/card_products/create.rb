module AdminArea::CardProducts
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :card_product)
    step Contract::Persist()
  end
end
