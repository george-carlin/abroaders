require 'abroaders/cell/result'

class Balance < Balance.superclass
  module Cell
    # The top-level cell for the balances#index action.
    #
    # @!method self.call(result, opts = {})
    #   @param result [Result] the result of Balance::Operation::Index
    #   @option result [Account] account the currently-logged in Account
    #   @option result [Collection<Person>] people
    class Index < Trailblazer::Cell
      extend Abroaders::Cell::Result
      include ::Cell::Builder

      skill :account
      skill :people

      def show
        aw = if account.connected_to_award_wallet?
               cell(AwardWalletInfo, account.award_wallet_user)
             else
               cell(AwardWalletConnectPanel)
             end
        main = cell(BalanceTable, collection: people)
        "#{aw} #{main}"
      end

      # A panel that encourages the user to connect their Abroaders account to
      # their AwardWallet account. It's just static HTML so needs no arguments.
      #
      # This is a separate .hpanel that sits above the 'main' .hpanel.
      class AwardWalletConnectPanel < Abroaders::Cell::Base
        include FontAwesome::Rails::IconHelper

        AWARD_WALLET_URL = \
          'https://awardwallet.com/m/#/connections/approve/vnawwgqjyt/2'.freeze

        def link_to_connect_with_award_wallet
          link_to(
            AWARD_WALLET_URL,
            class: 'btn btn-danger3',
            style: 'background-color: #1fb6ff; color: #ffffff;',
          ) do
            "#{fa_icon(:plug)} Connect to AwardWallet"
          end
        end
      end

      # model: AwardWalletUser
      class AwardWalletInfo < Trailblazer::Cell
        property :user_name

        def link_to_settings
          link_to 'Manage settings', integrations_award_wallet_settings_path
        end
      end
    end
  end
end
