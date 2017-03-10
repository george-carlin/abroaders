module AdminArea
  module Offers
    module Operation
      class Verify < Trailblazer::Operation
        step :setup_model
        step :offer_live?
        failure :log_offer_dead
        step :verify!

        private

        def setup_model(opts, params:)
          opts['model'] = Offer.find(params[:id])
        end

        def offer_live?(model:, **)
          model.live?
        end

        def log_offer_dead(opts)
          opts['error'] = "Can't verify a dead offer"
        end

        def verify!(model:, **)
          model.update!(last_reviewed_at: Time.zone.now)
        end
      end
    end
  end
end
