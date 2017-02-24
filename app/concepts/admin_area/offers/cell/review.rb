module AdminArea
  module Offers
    module Cell
      class Review < Trailblazer::Cell
        # Takes an Offer, returns a link (an <a>, but styled liked a button)
        # that the admin can click to kill the offer
        class KillButton < Trailblazer::Cell
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
        class VerifyButton < Trailblazer::Cell
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
