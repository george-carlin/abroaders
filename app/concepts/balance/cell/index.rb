require 'abroaders/cell/result'

class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(result, opts = {})
    #   @param result [Result] the result of Balance::Operation::Index
    #   @option result [Account] account the currently-logged in Account
    #   @option result [Collection<Person>] people
    #   @option result [Collection<Balance>] balances
    class Index < Trailblazer::Cell
      include FontAwesome::Rails::IconHelper
      extend Abroaders::Cell::Result

      skill :account
      skill :people
      skill :balances

      def show
        people.map do |person|
          bals = balances.select { |b| b.person_id == person.id }
          cell(BalanceTable, person, use_name: use_name?, balances: bals)
        end.join
      end

      private

      # If true, refer to people by name ("Erik's points" etc.). Else, use
      # pronouns ("My points").
      def use_name?
        account.couples?
      end
    end
  end
end
