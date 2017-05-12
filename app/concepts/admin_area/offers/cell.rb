module AdminArea
  module Offers
    module Cell
      # Generic stuff for New and Edit
      class PageWithForm < Abroaders::Cell::Base
        property :card_product

        option :form

        def show
          render 'page_with_form' # use the same view for all subclasses
        end

        private

        def form_tag
          cell(Form, model, form: form)
        end

        def links
          ''
        end

        def product_summary
          cell(AdminArea::CardProducts::Cell::Summary, card_product)
        end
      end

      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class Edit < PageWithForm
        def title
          'Edit Card Offer'
        end

        private

        def links
          link_to('Show offer', admin_offer_path(model))
        end
      end

      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class New < PageWithForm
        def title
          product_name = cell(CardProduct::Cell::FullName, card_product, with_bank: true)
          "#{product_name} - New Offer"
        end
      end
    end
  end
end
