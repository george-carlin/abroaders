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
        !current_account.award_wallet?
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

        def edit_modal
          ''
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
          !current_account.award_wallet?
        end

        class AwardWallet < self
          include Integrations::AwardWallet::Links

          property :login
          property :last_retrieve_date

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
            button_tag(
              class: 'btn btn-primary btn-xs',
              'data-toggle': 'modal',
              'data-target': "##{modal_id}",
            ) do
              '<i class="fa fa-pencil"> </i> Edit'
            end
          end

          # Not ideal as we're outputting a ton of very-slightly-different
          # modals (the only difference is the link URLs), one for each AWA.
          def edit_modal
            cell(
              ::Abroaders::Cell::ChoiceModal,
              [
                {
                  link: {
                    href: edit_integrations_award_wallet_account_path(id),
                    text: 'Update balance only',
                  },
                  text: t('loyalty_account.update_balance_explanation'),
                },
                {
                  link: {
                    href: edit_account_on_award_wallet_path(model),
                    target: '_blank',
                    text: 'Edit on AwardWallet',
                  },
                  text: t('loyalty_account.edit_on_award_wallet_explanation'),
                },
              ],
              id: modal_id,
            )
          end

          def html_id
            "award_wallet_account_#{id}"
          end

          def modal_id
            "edit_award_wallet_account_#{id}_modal"
          end

          # The 'updated_at' columns just represents the time the the account
          # was updated in *our* database. (In the case where they've only just
          # connected their AW account, the updated_at timestamp for ALL AW
          # accounts will be right now.) Instead we should show the
          # last_retrieve_date, which is the last date at which AW knew the
          # balance to be accurate.
          #
          # However, bear in mind that the last_retrieve_date may be null.
          def updated_at
            if last_retrieve_date.nil?
              '<i class="fa fa-warning"> </i> Unknown</i>'
            else
              last_retrieve_date.strftime('%D')
            end
          end
        end
      end
    end
  end
end
