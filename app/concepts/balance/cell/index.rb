class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(account, opts = {})
    #   @param account [Account] the currently-logged in account. Make sure
    #     that the right associations are eager-loaded.
    class Index < Abroaders::Cell::Base
      property :people

      def show
        award_wallet.to_s << main.to_s << unassigned_accounts_panel.to_s
      end

      private

      def award_wallet
        cell(AwardWalletPanel, model)
      end

      def main
        cell(PersonPanel, collection: people)
      end

      def people
        super.sort_by(&:type).reverse
      end

      def unassigned_accounts_panel
        cell(UnassignedAccounts, model)
      end

      # @!method self.call(account, options = {})
      class UnassignedAccounts < Abroaders::Cell::Base
        property :unassigned_loyalty_accounts

        def show
          return '' if unassigned_loyalty_accounts.none?
          super
        end

        private

        def table
          cell(LoyaltyAccount::Cell::Table, unassigned_loyalty_accounts)
        end
      end
    end
  end
end
