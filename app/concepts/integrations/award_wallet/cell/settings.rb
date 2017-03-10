module Integrations::AwardWallet
  module Cell
    class Settings < Trailblazer::Cell
      extend Abroaders::Cell::Result
      include ActionView::Helpers::FormOptionsHelper
      include BootstrapOverrides

      skill :owners
      skill :account
      skill :user

      private

      def user_info
        cell(User::Cell::Info, user)
      end

      def owner_settings
        cell(ForOwner, collection: owners, account: account)
      end

      # @!method self.call(award_wallet_owner)
      class ForOwner < Trailblazer::Cell
        extend Abroaders::Cell::Options
        include ActionView::Helpers::FormOptionsHelper
        include ActionView::Helpers::NumberHelper
        # include ActionView::Helpers::TextHelper
        include BootstrapOverrides
        include Escaped

        property :award_wallet_accounts
        property :name

        option :account

        private

        def accounts_summary
          cell(AccountsSummary, nil, accounts: award_wallet_accounts, owner_name: name)
        end

        def form_to_update_person(&block)
          url  = integrations_award_wallet_owner_update_person_path(model)
          opts = { data: { remote: true }, style: 'display:inline-block;' }
          form_tag(url, opts, &block)
        end

        def person_id_select
          options = options_from_collection_for_select(
            account.people, :id, :first_name, selected: model.person_id,
          )
          select(
            :award_wallet_owner,
            :person_id,
            options,
            { include_blank: 'Other' },
            class: 'input-sm',
          )
        end
      end

      class AccountsSummary < Trailblazer::Cell
        extend Abroaders::Cell::Options

        option :accounts
        option :owner_name

        def show
          result = "#{owner_name} has "
          # they should always have at least one account, else the owner
          # shouldn't exist in the first place:
          raise unless accounts.size >= 1
          result << "#{pluralize(accounts.size, 'account')} on AwardWallet"
          currencies = accounts.first(3).map(&:display_name).to_sentence
          result << if accounts.size <= 3
                      ": #{currencies}."
                    else
                      ", including #{currencies}."
                    end
        end
      end
    end
  end
end
