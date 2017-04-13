module AdminArea
  module Offers
    module Operation
      # Find a Card by its ID, and prepare to edit it
      class Edit < Trailblazer::Operation
        extend Contract::DSL
        contract Offers::Form

        step :setup_model
        step Contract::Build()

        private

        def setup_model(opts, params:, **)
          id = params.fetch(:id)
          if params[:card_product_id]
            opts['card_product'] = CardProduct.find(params[:card_product_id])
            opts['model'] = opts['card_product'].offers.find(id)
          else
            # the controller will use this offer to redirect to the correct
            # path:
            opts['model'] = Offer.includes(:product).find(id)
            false
          end
        end
      end
    end
  end
end
