require 'inflecto'

module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer)
      #   @param offer [Offer]
      class Show < Abroaders::Cell::Base
        property :id
        property :bank_name
        property :card_product
        property :condition
        property :cost
        property :link
        property :notes
        property :partner
        property :points_awarded

        def title
          "Offer ##{id}"
        end

        private

        def cost
          number_to_currency(super)
        end

        def condition
          Inflecto.humanize(super)
        end

        def days
          return '' if model.condition == 'on_approval'
          <<-HTML
            <dt>Days:</dt>
            <dd>#{model.days}</dd>
          HTML
        end

        def link_to_back
          link_to 'Back', admin_offers_path
        end

        def link_to_edit
          link_to 'Edit', edit_admin_offer_path(id)
        end

        def link_to_link
          link_to link, link, rel: 'nofollow'
        end

        def partner_name
          cell(Partner::Cell::FullName, partner)
        end

        def points_awarded
          number_with_delimiter(super)
        end

        def card_product_summary
          cell(CardProducts::Cell::Summary, card_product)
        end

        def spend
          return '' unless model.condition == 'on_minimum_spend'
          <<-HTML
            <dt>Spend:</dt>
            <dd>#{number_to_currency(model.spend)}</dd>
          HTML
        end
      end
    end
  end
end
