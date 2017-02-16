require 'abroaders/cell/result'

class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(result, opts = {})
    #   @param result [Result] the result of Balance::Operation::Index
    #   @option result [Account] account the currently-logged in Account
    #   @option result [Hash] people_with_balances a hash with Person objects
    #     as the keys, and the Balances of each pereson as the values.
    class Index < Trailblazer::Cell
      include FontAwesome::Rails::IconHelper
      extend Abroaders::Cell::Result

      skill :account
      skill :people_with_balances

      def show
        people_with_balances.map do |person, balances|
          cell(BalanceTable, person, use_name: use_name?, balances: balances)
        end.join # people_with_balances.each
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
