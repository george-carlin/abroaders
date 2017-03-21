class Account < Account.superclass
  module Operation
    class Dashboard < Trailblazer::Operation
      success :setup_unresolved_recommendations!

      private

      def setup_unresolved_recommendations!(opts, account:, **)
        opts['unresolved_recommendations'] = account.card_recommendations.unresolved
      end
    end
  end
end
