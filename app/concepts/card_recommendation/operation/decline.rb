class CardRecommendation < CardRecommendation.superclass
  module Operation
    # params:
    #   id: the ID of the CardRecommendation
    #   card:
    #     decline_reason
    # options:
    #   account: the currently-logged in user account
    class Decline < Trailblazer::Operation
      step :setup_model!
      step :rec_is_declinable?
      failure :rec_is_not_declinable!
      step :decline_rec!

      private

      def setup_model!(opts, account:, params:)
        opts['model'] = account.card_recommendations.find(params.fetch(:id))
      end

      def rec_is_declinable?(model:, **)
        model.declinable?
      end

      def rec_is_not_declinable!(opts)
        opts['error'] = COULDNT_DECLINE
      end

      def decline_rec!(model:, params:, **)
        reason = params.fetch(:card).fetch(:decline_reason).strip
        # empty strings should have been caught by the frontend, so we don't
        # need to handle them gracefully:
        raise if reason.empty?
        # TODO declined_at should be a datetime col in DB, not a date
        model.update!(decline_reason: reason, declined_at: Date.today)
      end

      COULDNT_DECLINE = "Couldn't decline card recommendation. This may "\
                        'happen if you already declined or accepted the '\
                        'recommendation in a different browser window, or if '\
                        "you hit the 'back' button after accepting or "\
                        'declining the first time.'.freeze
    end
  end
end
