class Balance < Balance.superclass
  module Operation
    class Index < Trailblazer::Operation
      success :setup_balances_and_people!

      private

      def setup_balances_and_people!(opts, account:, **)
        # a hash with Persons as the keys and their Balances as the values:
        opts['people_with_balances'] = account.balances.group_by(&:person)
      end
    end
  end
end
