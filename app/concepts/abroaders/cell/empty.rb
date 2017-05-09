module Abroaders
  module Cell
    # A generic cell that always returns an empty string. Useful in builders
    # sometimes.
    class Empty < Abroaders::Cell::Base
      def show
        ''
      end
    end
  end
end
