class Card < Card.superclass
  module Cell
    # takes a Card. returns a .row div containing the basic overview of the card:
    #   - card picture
    #   - card name and bank
    #   - card opened/closed dates
    #
    # options:
    #   - editable: default false. If true, display a link to the card's edit page,
    #               and a link to delete the card
    class BasicCard < Abroaders::Cell::Base
      property :id
      property :closed_at
      property :opened_at
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
        !model.closed_at.nil?
      end

      def closed_at
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
          card_path(model),
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
          edit_card_path(model),
          class: 'btn btn-primary btn-xs',
        )
      end

      def opened_at
        super.strftime(MONTH_YEAR_FORMAT)
      end
    end
  end
end
