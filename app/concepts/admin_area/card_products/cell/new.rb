module AdminArea::CardProducts
  module Cell
    # @!method self.call(card_product, options = {})
    #   @options options [Reform::Form] form]
    class New < Abroaders::Cell::Base
      option :form

      def title
        'New Card Product'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag
        cell(Form, model, form: form)
      end
    end
  end
end
