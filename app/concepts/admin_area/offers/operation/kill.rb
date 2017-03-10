module AdminArea
  module Offers
    module Operation
      # kill an offer (duh). The only required param is the offer's ID.
      class Kill < Trailblazer::Operation
        step :setup_model
        step :offer_live?
        failure :log_offer_already_killed
        step :kill!

        private

        def setup_model(opts, params:)
          opts['model'] = Offer.find(params[:id])
        end

        def offer_live?(model:, **)
          model.live?
        end

        def log_offer_already_killed(opts)
          opts['error'] = 'Offer already killed'
        end

        def kill!(model:, **)
          model.update!(killed_at: Time.zone.now)
        end
      end
    end
  end
end
