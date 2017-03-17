module Integrations::AwardWallet
  module Cell
    class Settings < Abroaders::Cell::Base
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
      class ForOwner < Abroaders::Cell::Base
        include ActionView::Helpers::FormOptionsHelper
        include ::Cell::Erb
        include ActionView::Helpers::NumberHelper
        # include ActionView::Helpers::TextHelper
        include BootstrapOverrides
        include Escaped

        property :id
        property :award_wallet_accounts
        property :name

        option :account

        private

        def accounts_summary
          cell(AccountsSummary, nil, accounts: award_wallet_accounts, owner_name: name)
        end

        def form_to_update_person(&block)
          form_tag(
            update_person_integrations_award_wallet_owner_path(model),
            {
              data: { remote: true },
              method: :patch,
              style: 'display:inline-block;',
              class: 'owner_update_person_form',
            },
            &block
          )
        end

        def person_id_select
          options = options_from_collection_for_select(
            account.people, :id, :first_name, selected: model.person_id,
          )
          select_tag(
            :person_id,
            options,
            include_blank: 'Someone else',
            id: "award_wallet_owner_#{id}_person_id",
            class: 'award_wallet_owner_person_id input-sm',
          )
        end
      end

      class AccountsSummary < Abroaders::Cell::Base
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
