module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class Edit < New
        def title
          'Edit Card Offer'
        end

        private

        def links
          link_to('Show offer', admin_offer_path(model))
        end
      end
    end
  end
end
