module AdminArea::CardProducts
  class Update < Trailblazer::Operation
    step Nested(Edit)
    step Contract::Validate(key: :card_product)
    step Contract::Persist()
  end
end
