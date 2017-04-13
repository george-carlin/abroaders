require 'abroaders/cell/options'

module AdminArea
  module People
    module Cell
      # If the person has balances, lists them with a header and a <ul>. Else
      # returns a simple string with a message saying that the person has no
      # balances.
      #
      # @!method self.call(person, opts = {})
      #   @param person [Person]
      #     The cell will call balance.currency.name on each person so be wary
      #     of N+1 issues
      class Balances < Abroaders::Cell::Base
        property :balances

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
          cell(::Balance::Cell::List, balances).to_s
        end
      end
    end
  end
end
