class Offer < Offer.superclass
  module Cell
    # takes an offer, returns how many points that offer awards
    # as a comma-delimited number string
    class PointsAwarded < Abroaders::Cell::Base
      def show
        number_with_delimiter(model.points_awarded)
      end
    end
  end
end
