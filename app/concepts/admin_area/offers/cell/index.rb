module AdminArea::Offers
  module Cell
    # @!method self.call(offers, options = {})
    #   @param offers [Collection<Offer>]
    class Index < Abroaders::Cell::Base
      def title
        if params[:card_product_id]
          product = model.first.card_product
          name = cell(CardProduct::Cell::FullName, product, with_bank: true)
          "#{name} - Offers"
        else
          'All Offers'
        end
      end

      private

      def table_rows
        cell(Row, collection: model)
      end

      # @!method self.call(offer, options = {})
      class Row < Abroaders::Cell::Base
        property :id
        property :card_product
        property :card_product_name
        property :cost
        property :bank_name
        property :days
        property :partner
        property :points_awarded
        property :spend

        private

        def cost
          number_to_currency(super)
        end

        def last_reviewed_at
          cell(AdminArea::Offers::Cell::LastReviewedAt, model)
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
