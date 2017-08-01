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
        property :link
        property :partner
        property :points_awarded
        property :spend

        private

        def card_product_name_link_to_offers
          name = cell(CardProduct::Cell::FullName, card_product, with_bank: true)
          link_to(
            "#{name} (#{card_product.bp[0].upcase})",
            admin_card_product_offers_path(card_product),
          )
        end

        def cost
          number_to_currency(super)
        end

        def details
          cell(AdminArea::Offers::Cell::Identifier, model, with_partner: true)
        end

        def last_reviewed_at
          super ? super.strftime('%m/%d/%Y') : 'never'
        end

        def link_to_edit
          link_to 'Edit', edit_admin_offer_path(model)
        end

        def link_to_link
          link_to 'URL', link, target: '_blank'
        end

        def link_to_show(text:)
          link_to text, admin_offer_path(model)
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

        def kill_btn
          # use link_to, not button_to, so the styles work with a .btn-group.
          link_to(
            'Kill',
            kill_admin_offer_path(id),
            class:  "kill_offer_btn btn btn-xs btn-danger",
            id:     "kill_offer_#{id}_btn",
            method: :patch,
            data: { confirm: 'Are you sure?' },
          )
        end

        def verify_btn
          # use link_to, not button_to, so the styles work with a .btn-group.
          link_to(
            'Verify',
            verify_admin_offer_path(id),
            class:  'verify_offer_btn btn btn-xs btn-primary',
            id:     "verify_offer_#{id}_btn",
            method: :patch,
          )
        end
      end
    end
  end
end
