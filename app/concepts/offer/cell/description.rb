class Offer < Offer.superclass
  module Cell
    # returns a nice English sentence that describes how one
    # can earn the offer's bonus.
    #
    # @!method self.call(offer, options = {})
    class Description < Abroaders::Cell::Base
      property :days

      def show
        case model.condition
        when 'on_minimum_spend'
          "Spend #{spend} within #{days} days to receive a bonus of "\
            "#{points_awarded} #{currency_name} points"
        when 'on_approval'
          "#{points_awarded} #{currency_name} points awarded upon a successful application for this card."
        when 'on_first_purchase'
          "#{points_awarded} #{currency_name} points awarded upon making your first purchase using this card."
        else raise 'this should never happen'
        end
      end

      private

      def currency_name # sorry, Mr. Demeter:
        model.product.currency.name
      end

      def points_awarded
        PointsAwarded.(model).()
      end

      def spend
        Spend.(model).()
      end
    end
  end
end
