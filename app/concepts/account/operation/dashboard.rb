class Account < Account.superclass
  module Operation
    class Dashboard < Trailblazer::Operation
      success :setup_actionable_recommendations!

      private

      # REFACTORME another unnecessary complication; just pass the account
      # directly to the cell
      def setup_actionable_recommendations!(opts, account:, **)
        opts['actionable_recommendations'] = account.actionable_card_recommendations
      end
    end
  end
end
