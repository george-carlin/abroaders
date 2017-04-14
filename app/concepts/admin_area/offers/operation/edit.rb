module AdminArea
  module Offers
    module Operation
      # Find an Offer by its ID, and prepare to edit it
      class Edit < Trailblazer::Operation
        extend Contract::DSL
        contract Offers::Form

        step :find_model
        step Contract::Build()

        private

        def find_model(opts, params:, **)
          opts['model'] = Offer.find(params.fetch(:id))
        end
      end
    end
  end
end
