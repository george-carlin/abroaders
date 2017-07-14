module AdminArea::Offers
  module Cell
    # @!method self.call(offers, options = {})
    #   @param offers [Collection<Offer>]
    #   @option options [CardProduct] card_product optional
    class Index < Abroaders::Cell::Base
      property :any?

      # If a card product is provided then the cell will assume that all the
      # offers in `model` belong to that product.
      option :card_product, optional: true

      def title
        if card_product.nil?
          'All Offers'
        else
          "#{card_product_name} - Offers"
        end
      end

      private

      def table_rows
        cell(Row, collection: model)
      end

      def card_product_name
        cell(CardProduct::Cell::FullName, card_product, with_bank: true)
      end

      # @!method self.call(offer, options = {})
      class Row < Abroaders::Cell::Base
        property :id
        property :card_product
        property :card_product_name
        property :cost
        property :bank_name
        property :days
        property :last_reviewed_at
        property :partner
        property :points_awarded
        property :spend

        private

        def cost
          number_to_currency(super)
        end

        def last_reviewed_at
          super ? super.strftime('%m/%d/%Y') : 'never'
        end

        def link_to_card_product_offers
          link_to(
            card_product_name,
            admin_card_product_offers_path(card_product),
          )
        end

        def live
          model.live? ? 'Yes' : 'No'
        end

        def partner
          cell(Partner::Cell::ShortName, super)
        end

        def points_awarded
          number_with_delimiter(super)
        end

        def spend
          number_to_currency(super)
        end
      end
    end
  end
end
