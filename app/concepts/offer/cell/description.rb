class Offer < Offer.superclass
  module Cell
    # returns a nice English sentence that describes how one can earn the
    # offer's bonus.
    #
    # @!method self.call(offer, options = {})
    class Description < Abroaders::Cell::Base
      property :condition
      property :currency
      property :currency_name
      property :days
      property :points_awarded
      property :spend

      def show
        # technically it doesn't make sense for an offer to be anything other
        # than 'no_bonus' if the product as no currency... but we don't enforce
        # this, so make sure it's handled gracefully.
        return '' if currency.nil?

        case condition
        when 'on_minimum_spend'
          "Spend #{spend} within #{days} days to receive a bonus of "\
            "#{points_awarded} #{currency_name} points"
        when 'on_approval'
          "#{points_awarded} #{currency_name} points awarded upon a successful application for this card."
        when 'on_first_purchase'
          "#{points_awarded} #{currency_name} points awarded upon making your first purchase using this card."
        when 'no_bonus'
          ''
        else raise 'this should never happen'
        end
      end

      private

      def points_awarded
        number_with_delimiter(super)
      end

      def spend
        number_to_currency(super)
      end
    end
  end
end
