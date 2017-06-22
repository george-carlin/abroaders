module AdminArea::CardProducts
  module Cell
    # @!method self.call(card_product, options = {})
    class New < Abroaders::Cell::Base
      def title
        'New Card Product'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end

      def form
        cell(Form, model)
      end
    end
  end
end
