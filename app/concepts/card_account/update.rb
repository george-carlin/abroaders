class CardAccount < CardAccount.superclass
  class Update < Trailblazer::Operation
    step Nested(Edit), name: 'nested.edit'
    step Contract::Validate(key: :card)
    step Contract::Persist()
  end
end
