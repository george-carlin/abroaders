module Integrations::AwardWallet
  module Cell
    class Settings < Abroaders::Cell::Base
      extend Abroaders::Cell::Result
      include ActionView::Helpers::FormOptionsHelper
      include BootstrapOverrides
      include Escaped

      skill :account
      skill :owners
      skill :user

      def title
        'AwardWallet settings'
      end

      private

      def user_name
        escape!(user.user_name)
      end

      def user_info
        cell(User::Cell::Info, user)
      end

      def owner_settings
        cell(ForOwner, collection: owners, account: account).join('<hr>') do |cell, i|
          cell.show(index: i)
        end
      end

      # @!method self.call(award_wallet_account)
      #   @param award_wallet_account [AwardWalletAccount]
      class Accounts < Abroaders::Cell::Base
        include Escaped

        property :display_name
        property :owner_name
        property :balance_raw

        def show
          <<-HTML
            <tr>
              <td>#{display_name}</td>
              <td>#{owner_name}</td>
              <td>#{balance_raw}</td>
            </tr>
          HTML
        end

        # @!method self.call(award_wallet_owner)
        #   @param owner [AwardWalletOwner]
        class Table < Abroaders::Cell::Base
          property :award_wallet_accounts

          private

          def rows
            # sort_by.reverse is faster than sort_by { (opposite of <=>) }:
            # http://stackoverflow.com/a/2651028/1603071
            ordered_accounts = award_wallet_accounts.sort_by(&:balance_raw).reverse
            cell(Accounts, collection: ordered_accounts)
          end
        end
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

        def show(opts = {})
          # assume this is the first person if it hasn't been specified
          @index = opts.fetch(:index, 0)
          render
        end

        private

        def accounts_table
          cell(Integrations::AwardWallet::Cell::Settings::Accounts::Table, model)
        end

        def first?
          @index == 0
        end

        def form_to_update_person(&block)
          form_tag(
            update_person_integrations_award_wallet_owner_path(model),
            {
              data: { remote: true },
              method: :patch,
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
    end
  end
end
