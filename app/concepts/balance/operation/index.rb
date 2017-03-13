class Balance < Balance.superclass
  module Operation
    class Index < Trailblazer::Operation
      success :setup_balances_and_people!

      private

      def setup_balances_and_people!(opts, account:, **)
        opts['people'] = account.people.order(owner: :desc)
        # eager-load balances:
        opts['people'].each { |p| p.balances.includes(:currencies) }
      end
    end
  end
end
