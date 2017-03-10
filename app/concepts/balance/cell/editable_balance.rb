class Balance < Balance.superclass
  module Cell
    # A <div> for a balance on the page. Displays the balance's value and
    # currency, and has buttons to edit or delete it. With JS, clicking 'edit'
    # will show a form to update the balance's value which saves via AJAX.
    #
    # @!method self.call(balance, opts = {})
    #   @param balance [Balance]
    class EditableBalance < Trailblazer::Cell
      include BootstrapOverrides
      include Escaped

      property :id
      property :currency_name
      property :value

      private

      def cancel_btn
        button_tag(
          'Cancel',
          class: 'cancel_edit_balance_btn btn btn-sm btn-default',
          data: { 'balance-id': id },
        )
      end

      def delete_btn
        link_to(
          'Delete',
          balance_path(id),
          class: 'destroy_balance_btn btn btn-sm btn-primary',
          data: {
            confirm: 'Are you sure? You can not undo this action',
          },
          method: :delete,
        )
      end

      def edit_btn
        button_tag(
          'Edit',
          class: 'edit_balance_btn btn btn-sm btn-primary',
          'data-balance-id': id,
        )
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
          &block
        )
      end

      def loading_spinner
        content_tag(
          :div,
          '',
          class: 'LoadingSpinner',
          style: 'float: right; top: 13px; right: 22px; display:none;',
        )
      end

      def save_btn
        button_tag(
          'Save',
          class: 'save_balance_btn btn btn-sm btn-primary',
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

      def formatted_value
        cell(Balance::Cell::Value, model)
      end

      def value_field
        number_field(
          :balance,
          :value,
          class: 'balance_value_editing',
          style: 'display: none; height: 30px;',
          value: value,
        )
      end

      def wrapping_div(&block)
        content_tag(
          :div,
          class: 'balance row',
          id: "balance_#{id}",
          &block
        )
      end
    end
  end
end
