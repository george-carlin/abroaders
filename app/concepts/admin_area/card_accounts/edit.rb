module AdminArea
  module CardAccounts
    class Edit < Trailblazer::Operation
      step :nest_edit

      private

      # .Nested() doesn't pass skills to the nested operation, so we have to
      # do it the hard way. In a future version of TRB we'll be able to do
      # this with Nested(inner: ...). See
      # https://github.com/trailblazer/trailblazer/issues/166.
      def nest_edit(options, params:, **)
        result = CardAccount::Edit.(params, 'card_scope' => Card)
        options['model'] = result['model']
        options['contract.default'] = result['contract.default']
      end
    end
  end
end
