class CardAccount < CardAccount.superclass
  module Cell
    # @method self.call(card_account, options = {})
    #   @option options [Reform::Form] form
    class Edit < Abroaders::Cell::Base
      property :card_product

      option :form

      def title
        'Edit Card'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for(
          form,
          url: card_account_path(model),
          html: { class: 'edit_card' },
          &block
        )
      end

      def card_product_summary
        cell(CardProduct::Cell::Summary, card_product)
      end
    end
  end
end
