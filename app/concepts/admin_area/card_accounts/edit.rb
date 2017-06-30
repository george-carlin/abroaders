module AdminArea
  module CardAccounts
    class Edit < Trailblazer::Operation
      step Nested(::CardAccount::Edit, input: -> (opts) do
        opts.to_hash.merge('card_scope' => Card.accounts)
      end,)
    end
  end
end
