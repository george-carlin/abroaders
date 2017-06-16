module AdminArea
  module Offers
    module Cell
      # The actual <form> tag on both the Edit and New pages
      #
      # @!method self.call(offer, options = {})
      #   @option options [Reform::Form] form
      class Form < Abroaders::Cell::Base
        property :card_product
        option :form

        private

        def button_to_unkill
          button_to(
            'Unkill Offer',
            unkill_admin_offer_path(model),
            class: 'btn btn-default',
            data: { confirm: 'Are you sure? ' },
            method: :patch,
          )
        end

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
              ['No bonus', 'no_bonus'],
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
    end
  end
end
