module AdminArea
  module Offers
    # kill an offer (duh).
    #
    # @!method self.call(params, options = {})
    #   @option params [Integer] offer_id required
    #   @option params [Integer] replacement_id optional. If
    #     replacement_id is specified AND the killed offer has any
    #     unresolved recs, then the unresolved recs will have their offer
    #     updated with the replacement
    class Kill < Trailblazer::Operation
      step :setup_model
      step :offer_live?
      failure :log_offer_already_killed
      success :replace
      step :kill!

      private

      def setup_model(opts, params:, **)
        opts['model'] = Offer.find(params.fetch(:id))
      end

      def offer_live?(model:, **)
        model.live?
      end

      def log_offer_already_killed(opts)
        opts['error'] = 'Offer already killed'
      end

      def replace(model:, params:, **)
        unresolved_recs = model.unresolved_recommendations
        unresolved_recs.size
        if params[:replacement_id] && unresolved_recs.any?
          replacement = Offer.find(params[:replacement_id])
          unresolved_recs.update_all(offer_id: replacement.id)
        end
      end

      def kill!(model:, **)
        model.update!(killed_at: Time.now)
      end
    end
  end
end
