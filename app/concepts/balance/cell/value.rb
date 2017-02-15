class Balance < Balance.superclass
  module Cell
    # Takes a `Balance`, returns its `value` as a comma-delimited string
    #
    # @!method self.call(balance)
    #   @param balance [Balance]
    class Value < Trailblazer::Cell
      include ActionView::Helpers::NumberHelper

      def show
        number_with_delimiter(model.value)
      end
    end
  end
end
