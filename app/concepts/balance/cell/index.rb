class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(account, opts = {})
    #   @param account [Account] the currently-logged in account. Make sure
    #     that the right associations are eager-loaded.
    class Index < Abroaders::Cell::Base
      property :award_wallet?
      property :people

      def show
        "#{award_wallet} #{main} #{unassigned_accounts_panel} #{sync_balances_modal}"
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

      # Modal that will be shown when they click the button 'Sync balances'.
      # As this button is only shown when they're connected to AW, there's no
      # need to output the modal if they're not connected to AW.
      def sync_balances_modal
        return '' unless award_wallet?
        cell(
          Abroaders::Cell::ChoiceModal,
          [
            {
              link_href: 'https://awardwallet.com/account/list',
              link_text: 'Update Balances',
              text: "This option will direct you to the AwardWallet website "\
                    "to update your balances from your loyalty program "\
                    "accounts. If your points balances are out of date on "\
                    "AwardWallet, you should do this before importing "\
                    "balances to Abroaders.",
            },
            {
              link_href: integrations_award_wallet_sync_path,
              link_text: 'Import Balances',
              text: "This option will import your points balances from "\
                    "AwardWallet to Abroaders. AwardWallet will not check "\
                    "your loyalty accounts for the most recent balance "\
                    "information if you choose this option.",
            },
          ],
          id: 'sync_balances_modal',
        )
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
