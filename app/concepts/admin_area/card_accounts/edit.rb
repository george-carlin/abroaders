module AdminArea
  module CardAccounts
    class Edit < Trailblazer::Operation
      step Nested(::CardAccount::Edit, input: -> (opts) {
        opts.to_hash.merge('card_scope' => Card.accounts)
      })
    end
  end
end
