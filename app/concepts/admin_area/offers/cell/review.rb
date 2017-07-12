module AdminArea
  module Offers
    module Cell
      # @!method self.call(offers, options = {}) #   @param [Collection<Offer>] offers
      class Review < Abroaders::Cell::Base
        def title
          'Review Live Offers'
        end

        private

        def table_rows
          cell(Row, collection: model)
        end

        # @!method self.call(offer, options = {})
        #   @param [Offer] offer
        class Row < Abroaders::Cell::Base
          property :id
          property :card_product
          property :cost
          property :link
          property :points_awarded
          property :spend

          private

          def card_product_name
            cell(CardProduct::Cell::FullName, card_product, with_bank: true)
          end

          def cost
            number_to_currency(super)
          end

          def details
            cell(Offers::Cell::Identifier, model, with_partner: true)
          end

          def kill_btn
            # use link_to, not button_to, so the styles work with a .btn-group.
            link_to(
              'Kill',
              kill_admin_offer_path(id),
              class:  "kill_offer_btn btn btn-xs btn-danger",
              id:     "kill_offer_#{id}_btn",
              method: :patch,
              remote: true,
              data: { confirm: 'Are you sure?' },
            )
          end

          def last_reviewed_at
            cell(AdminArea::Offers::Cell::LastReviewedAt, model)
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

          def unresolved_recs_count
            # This causes a massive N+1 queries issue; it needs a counter cache
            # column. However, this page won't get viewed often so I think we
            # can get away without one for now.
            model.unresolved_recommendations.size
          end

          def verify_btn
            # use link_to, not button_to, so the styles work with a .btn-group.
            link_to(
              'Verify',
              verify_admin_offer_path(id),
              class:  'verify_offer_btn btn btn-xs btn-primary',
              id:     "verify_offer_#{id}_btn",
              method: :patch,
              remote: true,
            )
          end
        end
      end
    end
  end
end
