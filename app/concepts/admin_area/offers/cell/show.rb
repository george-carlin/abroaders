require 'inflecto'

module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer)
      #   @param offer [Offer]
      class Show < Abroaders::Cell::Base
        property :id
        property :condition
        property :link
        property :partner
        property :product
        property :notes

        def title
          "Offer ##{id}"
        end

        private

        def bank_name
          product.bank.name
        end

        def cost
          cell(Offer::Cell::Cost, model)
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
          Partner::Cell::FullName.(partner)
        end

        def points_awarded
          cell(Offer::Cell::PointsAwarded, model)
        end

        def product_summary
          cell(CardProducts::Cell::Summary, product)
        end

        def spend
          return '' unless model.condition == 'on_minimum_spend'
          <<-HTML
            <dt>Spend:</dt>
            <dd>#{cell(Offer::Cell::Spend, model)}</dd>
          HTML
        end
      end
    end
  end
end
