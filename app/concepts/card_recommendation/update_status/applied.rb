class CardRecommendation < CardRecommendation.superclass
  module UpdateStatus
    class Applied < Trailblazer::Operation
      success :setup_model
      step :rec_can_be_applied_for?
      failure :log_rec_unapplyable
      step :mark_rec_as_applied

      private

      def setup_model(opts, current_account:, params:, **)
        opts['model'] = current_account.card_recommendations.find(params.fetch(:id))
      end

      def rec_can_be_applied_for?(model:, **)
        model.unresolved?
      end

      def log_rec_unapplyable(opts)
        opts['error'] = I18n.t('cards.invalid_status_error')
      end

      def mark_rec_as_applied(model:, **)
        model.update!(applied_on: Date.today)
      end
    end
  end
end
