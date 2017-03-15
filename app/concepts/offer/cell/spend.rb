class Offer < ApplicationRecord
  module Cell
    # takes an offer, returns its spend in the format '$X.XX'
    class Spend < Abroaders::Cell::Base
      property :spend

      def show
        number_to_currency(spend)
      end
    end
  end
end
