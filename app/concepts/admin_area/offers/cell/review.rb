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
          property :bank_name
          property :card_product
          property :card_product_name
          property :days
          property :link

          private

          def cost
            cell(Offer::Cell::Cost, model)
          end

          def last_reviewed_at
            cell(AdminArea::Offers::Cell::LastReviewedAt, model)
          end

          def kill_btn
            cell(AdminArea::Offers::Cell::Review::KillButton, model)
          end

          def link_to_edit
            link_to 'Edit', edit_admin_offer_path(model)
          end

          def link_to_link
            link_to 'Link', link, target: '_blank'
          end

          def points_awarded
            cell(Offer::Cell::PointsAwarded, model)
          end

          def spend
            cell(Offer::Cell::Spend, model)
          end

          def verify_btn
            cell(AdminArea::Offers::Cell::Review::VerifyButton, model)
          end
        end

        # Takes an Offer, returns a link (an <a>, but styled liked a button)
        # that the admin can click to kill the offer
        class KillButton < Abroaders::Cell::Base
          property :id

          def show
            # use link_to, rather than an actual button, so that we can style it
            # properly with a .btn-group
            link_to(
              'Kill',
              kill_admin_offer_path(id),
              class:  "kill_offer_btn btn btn-xs btn-danger",
              id:     "kill_offer_#{id}_btn",
              params: { offer_id: id },
              method: :patch,
              remote: true,
              data: { confirm: 'Are you sure?' },
            )
          end
        end

        # Takes an Offer, returns a link (an <a>, but styled liked a button)
        # that the admin can click to verify the offer is still live
        class VerifyButton < Abroaders::Cell::Base
          property :id

          def show
            # use link_to, rather than an actual button, so that we can style it
            # properly with a .btn-group
            link_to(
              'Verify',
              verify_admin_offer_path(id),
              class:  'verify_offer_btn btn btn-xs btn-primary',
              id:     "verify_offer_#{id}_btn",
              params: { offer_id: id },
              method: :patch,
              remote: true,
            )
          end
        end
      end
    end
  end
end
