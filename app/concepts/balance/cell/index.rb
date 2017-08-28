class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(account, opts = {})
    #   @param account [Account] the currently-logged in account. Make sure
    #     that the right associations are eager-loaded.
    class Index < Abroaders::Cell::Base
      include Integrations::AwardWallet::Links

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
              link: {
                href: award_wallet_account_list_url,
                text: 'Update Balances',
              },
              text: t('balance.sync_balances_modal.award_wallet.text'),
            },
            {
              link: {
                href: integrations_award_wallet_sync_path,
                text: 'Import Balances',
              },
              text: t('balance.sync_balances_modal.abroaders.text'),
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
          cell(
            LoyaltyAccount::Cell::Table,
            unassigned_loyalty_accounts,
            account: model,
          )
        end
      end
    end
  end
end
