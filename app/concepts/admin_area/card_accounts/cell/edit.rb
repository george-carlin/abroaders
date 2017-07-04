module AdminArea::CardAccounts
  module Cell
    # @!method self.call(model, options = {})
    #   @option options [Reform::Form] form
    class Edit < Abroaders::Cell::Base
      option :form

      def title
        'Edit Card'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for form, url: admin_card_account_path(form.model), &block
      end
    end
  end
end
