class Card < ApplicationRecord
  module Cell
    # takes a Card. returns a .row div containing the basic overview of the card:
    #   - card picture
    #   - card name and bank
    #   - card opened/closed dates
    #
    # options:
    #   - editable: default false. If true, display a link to the card's edit page
    class BasicCard < Trailblazer::Cell
      property :id
      property :closed_at
      property :opened_at
      property :product

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

      def full_name
        cell(CardProduct::Cell::FullName, product, network_in_brackets: true)
      end

      def html_id
        "card_#{id}"
      end

      def html_classes
        'card row'
      end

      def image
        cell(CardProduct::Cell::Image, product, size: '130x81')
      end

      def link_to_edit
        link_to 'Edit', edit_card_path(model)
      end

      def opened_at
        super.strftime(MONTH_YEAR_FORMAT)
      end
    end
  end
end
