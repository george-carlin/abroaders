class LoyaltyAccount < LoyaltyAccount.superclass
  module Cell
    # A <table> that lists all the given LoyaltyAccounts.
    #
    # @!method self.call(loyalty_accounts, options = {})
    #   @param loyalty_accounts [Collection<LoyaltyAccount>]
    class Table < ::Abroaders::Cell::Base
      private

      def headers
        cols = [
          'Award Program',
          ('Owner' unless simple),
          ('Account' unless simple),
          'Balance',
          ('Expires' unless simple),
          'Last Updated',
          '',
        ].compact
        cols.map { |text| "<th>#{text}</th>" }
      end

      def rows
        cell(Row, collection: model.sort_by(&:currency_name))
      end

      #  when this returns true, a few of the columns in the table won't be
      #  displayed. Will be true when the current account has no award
      #  wallet connection. Since non-AW accounts don't have an expiration
      #  date, a 'login' name or an owner, there's no point displaying the
      #  columns because they'll be blank for all rows.
      def simple
        !current_account.connected_to_award_wallet?
      end

      # A <tr> for a loyalty_account on the page. Displays the balance's value
      # and currency, and has buttons to edit or delete/hide it. If it's an
      # Abroaders balance, then 'edit' will show a form to update the balance's
      # value via AJAX.
      #
      # @!method self.call(loyalty_account, opts = {})
      #   @param loyalty_account [LoyaltyAccount]
      class Row < ::Abroaders::Cell::Base
        include ::Cell::Builder
        include Escaped

        builds do |loyalty_account|
          case loyalty_account.source
          when 'abroaders' then self
          when 'award_wallet' then AwardWallet
          else raise "unrecognized source '#{loyalty_account.source}'"
          end
        end

        def show
          render 'table/row'
        end

        property :id
        property :balance_raw
        property :currency_name
        property :expiration_date
        property :login
        property :owner_name
        property :updated_at

        private

        def delete_btn
          link_to(
            balance_path(id),
            class: 'btn btn-xs btn-danger',
            data: { confirm: 'Are you sure? You can not undo this action' },
            method: :delete,
          ) do
            '<i class="fa fa-trash"> </i> Delete'
          end
        end

        def edit_btn
          link_to(
            edit_balance_path(id),
            class: 'btn btn-xs btn-primary',
          ) do
            '<i class="fa fa-pencil"> </i> Edit'
          end
        end

        def expiration_date
          cell(ExpirationDate, model)
        end

        def formatted_balance
          number_with_delimiter(balance_raw)
        end

        def html_id
          "balance_#{id}"
        end

        def updated_at
          super.strftime('%D')
        end

        def simple
          !current_account.connected_to_award_wallet?
        end

        class AwardWallet < self
          include Integrations::AwardWallet::Links

          property :login

          def icon
            image_tag(
              'aw_tiny.png',
              class: 'award_wallet_logo',
              size: '15x15',
              style: 'float: left',
              alt: "We're pulling this account's information from your AwardWallet account",
            )
          end

          def delete_btn
            ''
          end

          def edit_btn
            link_to(
              edit_account_on_award_wallet_path(model),
              class: 'edit_award_wallet_account_btn btn btn-xs btn-primary',
              target: '_blank',
            ) do
              '<i class="fa fa-pencil"> </i> Edit'
            end
          end

          def html_id
            "award_wallet_account_#{id}"
          end
        end
      end
    end
  end
end
