class Balance < Balance.superclass
  module Cell
    # takes a Balance, returns its value as a comma-delimited string
    class Value < Trailblazer::Cell
      include ActionView::Helpers::NumberHelper

      def show
        number_with_delimiter(model.value)
      end
    end
  end
end
