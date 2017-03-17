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
    class Index < Abroaders::Cell::Base
      extend Abroaders::Cell::Result
      include ::Cell::Builder

      skill :account
      skill :people
      skill :balances

      # If they've already connected their AwardWallet account, show
      # them AwardWalletInfo, which is a different page entirely:
      builds do |result, _options = {}|
        if result['account'].connected_to_award_wallet?
          AwardWalletInfo
        else
          self
        end
      end

      def show
        cell(AwardWalletConnectPanel).show + cell(Balances, balances, account: account).show
      end

      private

      def link_to_add_new_balance
        link_to(
          'Add new',
          new_person_balance_path(account.owner),
          class: 'btn btn-primary btn-sm',
          style: 'float: right; margin-bottom: 6px;',
        )
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

      # @param balances [Collection<Balance>]
      # @option opts [Collection<People>]
      class Balances < Abroaders::Cell::Base
        alias balances model

        option :account

        def show
          account.people.map do |person|
            bals = balances.select { |b| b.person_id == person.id }
            cell(BalanceTable, person, use_name: use_name?, balances: bals)
          end.join
        end

        private

        def use_name?
          account.couples?
        end
      end

      # when the user has connected their account to AwardWallet, show
      # this cell instead of the regular balance index:
      #
      # model: the result object
      class AwardWalletInfo < Abroaders::Cell::Base
        def success_alert
          if options[:flash] && options[:flash][:award_wallet] == 'connected'
            cell(SuccessAlert)
          else
            ''
          end
        end

        class SuccessAlert < Abroaders::Cell::Base
          include FontAwesome::Rails::IconHelper
        end
      end
    end
  end
end
