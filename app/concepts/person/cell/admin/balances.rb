class Person::Cell < Trailblazer::Cell
  module Admin
    # If the person has balances, displays them. Else displays a message
    # saying that the person has no balances.
    class Balances < Trailblazer::Cell
      property :balances

      include ActionView::Helpers::NumberHelper

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
        ::Balance::Cell::List.(balances.includes(:currency)).show
      end
    end
  end
end
