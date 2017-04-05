class Account < Account.superclass
  module Operation
    class Dashboard < Trailblazer::Operation
      success :setup_unresolved_recommendations!

      private

      def setup_unresolved_recommendations!(opts, account:, **)
        opts['unresolved_recommendations'] = account.unresolved_card_recommendations
      end
    end
  end
end
