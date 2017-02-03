class Offer < ApplicationRecord
  module Cell
    # takes an offer, returns how many points that offer awards
    # as a comma-delimited number string
    class PointsAwarded < Trailblazer::Cell
      include ActionView::Helpers::NumberHelper

      def show
        number_with_delimiter(model.points_awarded)
      end
    end
  end
end
