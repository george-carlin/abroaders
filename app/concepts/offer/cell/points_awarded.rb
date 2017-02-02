class Offer < ApplicationRecord
  class Cell < Trailblazer::Cell # TODO remove Offer::Cell; this should be a module
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
