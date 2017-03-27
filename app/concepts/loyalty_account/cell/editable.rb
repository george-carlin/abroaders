class LoyaltyAccount < LoyaltyAccount.superclass
  module Cell
    # A <div> for a loyalty_account on the page. Displays the balance's value
    # and currency, and has buttons to edit or delete/hide it. If it's an
    # Abroaders balance, then 'edit' will show a form to update the balance's
    # value via AJAX.
    #
    # @!method self.call(loyalty_account, opts = {})
    #   @param loyalty_account [LoyaltyAccount]
    class Editable < Abroaders::Cell::Base
      include ::Cell::Builder
      include Escaped

      builds do |loyalty_account|
        case loyalty_account.source
        when 'abroaders' then self
        when 'award_wallet' then AwardWallet
        else raise "unrecognized source '#{loyalty_account.source}'"
        end
      end

      property :id
      property :currency_name
      property :updated_at
      property :balance_raw

      private

      def cancel_btn
        button_tag(
          'Cancel',
          class: 'cancel_edit_balance_btn btn btn-xs btn-default',
          data: { 'balance-id': id },
        )
      end

      def delete_btn
        link_to(
          balance_path(id),
          class: 'destroy_balance_btn btn btn-xs btn-danger',
          data: {
            confirm: 'Are you sure? You can not undo this action',
          },
          method: :delete,
        ) do
          '<i class="fa fa-trash"> </i> Delete'
        end
      end

      def edit_btn
        button_tag(
          class: 'edit_balance_btn btn btn-xs btn-primary',
          'data-balance-id': id,
        ) do
          '<i class="fa fa-pencil"> </i> Edit'
        end
      end

      def updated_at
        super.strftime('%D')
      end

      def error_message
        content_tag(
          :span,
          'Invalid value',
          class: 'editing_balance_error_msg',
          style: 'display:none;',
        )
      end

      def form_tag(&block)
        super(
          balance_path(id),
          class: 'edit_balance',
          data: { remote: true },
          method: :patch,
          style: 'display:none;',
          &block
        )
      end

      def loading_spinner
        content_tag(
          :div,
          '',
          class: 'LoadingSpinner',
          style: 'display: none;',
        )
      end

      def save_btn
        button_tag(
          'Save',
          class: 'save_balance_btn btn btn-xs btn-primary',
          data:  { 'balance-id': id },
        )
      end

      def save_btn_group
        content_tag(
          :div,
          class: 'editing_balance_btn_group btn-group',
          style: 'display:none;',
        ) do
          yield
        end
      end

      def formatted_balance
        number_with_delimiter(balance_raw)
      end

      def value_field
        number_field(
          :balance,
          :value,
          class: 'balance_value_editing input-sm',
          style: 'display: none;',
          value: balance_raw,
        )
      end

      def wrapping_div(&block)
        content_tag(
          :div,
          class: 'balance row editable_balance',
          id: "balance_#{id}",
          &block
        )
      end

      class AwardWallet < self
        include Integrations::AwardWallet::Links

        property :login

        def aw_logo
          image_tag(
            'aw_tiny.png',
            class: 'award_wallet_logo',
            size: '15x15',
            style: 'float: left',
            alt: "We're pulling this account's information from your AwardWallet account",
          )
        end

        def edit_btn
          link_to(
            edit_account_on_award_wallet_path(model),
            class: 'edit_award_wallet_account_btn btn btn-xs btn-primary',
            target: '_blank',
          ) do
            '<i class="fa fa-pencil"> </i> Edit on AwardWallet.com'
          end
        end
      end
    end
  end
end
