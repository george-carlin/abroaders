require 'abroaders/cell/options'

module AdminArea
  module Person
    module Cell
      # If the person has balances, lists them with a header and a <ul>. Else
      # returns a simple string with a message saying that the person has no
      # balances.
      #
      # @!method self.call(person, opts = {})
      #   @param person [Person]
      #   @option opts [Collection<Balance>] balances the person's balances.
      #     The cell will call .currency.name on each balance so be wary of
      #     N+1 issues
      class Balances < Trailblazer::Cell
        extend Abroaders::Cell::Options

        option :balances

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
