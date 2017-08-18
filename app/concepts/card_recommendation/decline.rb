class CardRecommendation < CardRecommendation.superclass
  # @!method self.call(params, options = {})
  #   @option params [Integer] id the ID of the CardRecommendation
  #   @option params [Hash] card hash with key :decline_reason
  #   @option options [Account] current_account the currently-logged in user
  class Decline < Trailblazer::Operation
    step :setup_model!
    step :rec_is_declinable?
    failure :rec_is_not_declinable!
    step :decline_rec!

    private

    def setup_model!(opts, current_account:, params:, **)
      opts['model'] = current_account.card_recommendations.find(params.fetch(:id))
    end

    def rec_is_declinable?(model:, **)
      model.unresolved?
    end

    def rec_is_not_declinable!(opts)
      opts['error'] = COULDNT_DECLINE
    end

    def decline_rec!(model:, params:, **)
      reason = params.fetch(:card).fetch(:decline_reason).strip
      # empty strings should have been caught by the frontend, so we don't
      # need to handle them gracefully:
      raise if reason.empty?
      model.update!(decline_reason: reason, declined_at: Time.zone.now)
    end

    COULDNT_DECLINE = "Couldn't decline card recommendation. This may "\
      'happen if you already declined or accepted the '\
      'recommendation in a different browser window, or if '\
      "you hit the 'back' button after accepting or "\
      'declining the first time.'.freeze
  end
end
