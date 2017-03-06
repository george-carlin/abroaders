class Balance < Balance.superclass
  module Operation
    class Index < Trailblazer::Operation
      success :setup_balances_and_people!

      private

      def setup_balances_and_people!(opts, account:, **)
        opts['people']   = account.people
        opts['balances'] = account.balances
      end
    end
  end
end
