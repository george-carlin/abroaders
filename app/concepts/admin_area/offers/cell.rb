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

      # The actual <form> tag on both the Edit and New pages
      #
      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class Form < Abroaders::Cell::Base
        property :card_product
        option :form

        private

        def errors
          cell(Abroaders::Cell::ValidationErrorsAlert, form)
        end

        def form_tag(&block)
          url_models = [:admin, form]
          url_models.insert(1, card_product) unless form.persisted?
          form_for(
            url_models,
            html: { style: 'clear:both;', class: "form-horizontal", role: "form" },
            &block
          )
        end

        def options_for_offer_condition_select(offer)
          options_for_select(
            [
              ['Approval', 'on_approval'],
              ['First purchase', 'on_first_purchase'],
              ['Minimum spend', 'on_minimum_spend'],
            ],
            offer.condition,
          )
        end

        def options_for_offer_partner_select(offer)
          options_for_select(
            Offer::Partner.options[:values].map do |key|
              [Partner::Cell::FullName.(key), key]
            end,
            offer.partner,
          )
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
