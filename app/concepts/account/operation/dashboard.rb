class Account < Account.superclass
  module Operation
    class Dashboard < Trailblazer::Operation
      step :setup_people!
      step :setup_unresolved_recommendations!
      step :setup_travel_plans!

      private

      def setup_people!(opts, account:, **)
        opts['people'] = account.people.includes(
          :balances, :spending_info, cards: :product,
        ).order(owner: :desc)
      end

      def setup_travel_plans!(opts, account:, **)
        opts['travel_plans'] = account.travel_plans.includes_destinations
      end

      def setup_unresolved_recommendations!(opts, account:, **)
        opts['unresolved_recommendations'] = account.card_recommendations.unresolved
      end
    end
  end
end
