module AdminArea
  module CardAccounts
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :card_account)
      step Contract::Persist()
    end
  end
end
