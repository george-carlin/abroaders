class CardAccount < CardAccount.superclass
  module Cell
    # takes a card account. returns a .row div containing the basic overview of the card:
    #   - card product picture
    #   - card name and bank
    #   - card opened/closed dates
    #
    # @!method self.call(card_account, options = {})
    #   @param card_account
    #   @option options [Boolean] :editable default false. If true, display a
    #     link to the card account's edit page, and a link to delete it
    class Row < Abroaders::Cell::Base
      property :id
      property :closed_on
      property :opened_on
      property :product

      # Defining this as a method so we can stub it in tests. I need to think
      # of a better solution for DI. FIXME
      def self.product_name_cell
        CardProduct::Cell::FullName
      end

      private

      MONTH_YEAR_FORMAT = '%b %Y'.freeze

      def bank_name
        product.bank.name
      end

      def closed?
        !model.closed_on.nil?
      end

      def closed_on
        super.strftime(MONTH_YEAR_FORMAT)
      end

      def product_full_name
        cell(self.class.product_name_cell, product, network_in_brackets: true)
      end

      def html_classes
        'card row'
      end

      def html_id
        "card_#{id}"
      end

      def image
        cell(CardProduct::Cell::Image, product, size: '130x81')
      end

      def link_to_delete
        link_to(
          'Delete',
          card_account_path(model),
          class: 'btn btn-primary btn-xs',
          method: :delete,
          data: {
            confirm: 'Are you sure you want to remove this card from your '\
                     'account? You can not undo this action.',
          },
        )
      end

      def link_to_edit
        link_to(
          'Edit',
          edit_card_account_path(model),
          class: 'btn btn-primary btn-xs',
        )
      end

      def opened_on
        super.strftime(MONTH_YEAR_FORMAT)
      end
    end
  end
end
