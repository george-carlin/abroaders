class Offer < ApplicationRecord
  module Cell
    # takes an offer, returns its cost in the format '$X.XX'
    class Cost < Abroaders::Cell::Base
      property :cost

      def show
        number_to_currency(cost)
      end
    end
  end
end
