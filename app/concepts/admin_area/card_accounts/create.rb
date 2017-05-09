module AdminArea
  module CardAccounts
    class Create < Trailblazer::Operation
      step Nested(New)
      step Contract::Validate(key: :card_account)
      step Contract::Persist()
    end
  end
end
