class Balance < Balance.superclass
  module Operation
    class Index < Trailblazer::Operation
      success :setup_balances_and_people!

      private

      def setup_balances_and_people!(opts, account:, **)
        # a hash with Persons as the keys and their Balances as the values:
        pwb = {}
        pwb[account.owner] = account.owner.balances
        pwb[account.companion] = account.companion.balances if account.couples?
        opts['people_with_balances'] = pwb
      end
    end
  end
end
