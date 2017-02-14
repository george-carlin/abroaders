module AdminArea
  module Person
    module Cell
      # If the person has balances, displays them. Else displays a message
      # saying that the person has no balances.
      #
      # @!method self.call(model, opts = {})
      #   @param model [Person]
      #   @option opts [Collection<Balance>] the person's balances.
      #     The cell calls .currency.name on each balance so be wary of
      #     N+1 issues
      class Balances < Trailblazer::Cell
        property :balances

        include ActionView::Helpers::NumberHelper

        def show
          if balances.any?
            header + list
          else
            'User does not have any existing points/miles balances'
          end
        end

        private

        def header
          '<h3>Existing Balances</h3>'
        end

        def list
          cell(::Balance::Cell::List, options.fetch(:balances)).()
        end
      end
    end
  end
end
