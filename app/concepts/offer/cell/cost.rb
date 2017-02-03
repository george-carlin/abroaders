class Offer < ApplicationRecord
  module Cell
    # takes an offer, returns its cost in the format '$X.XX'
    class Cost < Trailblazer::Cell
      include ActionView::Helpers::NumberHelper

      property :cost

      def show
        number_to_currency(cost)
      end
    end
  end
end
