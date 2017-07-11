module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class New < Abroaders::Cell::Base
        property :card_product

        option :form

        subclasses_use_parent_view!

        def title
          "#{product_name} - New Offer"
        end

        private

        def form_tag
          cell(Form, model, form: form)
        end

        def links
          ''
        end

        def product_name
          cell(CardProduct::Cell::FullName, card_product, with_bank: true)
        end

        def product_summary
          cell(AdminArea::CardProducts::Cell::Summary, card_product)
        end
      end
    end
  end
end
