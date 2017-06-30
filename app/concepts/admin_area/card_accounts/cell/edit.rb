module AdminArea::CardAccounts
  module Cell
    # @!method self.call(form, options = {})
    #   @param form [Reform::Form]
    class Edit < Abroaders::Cell::Base
      def title
        'Edit Card'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end

      def form_tag(&block)
        form_for model, url: admin_card_account_path(model.model), &block
      end
    end
  end
end
