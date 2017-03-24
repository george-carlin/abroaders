class Balance < Balance.superclass
  module Cell
    # A <div> for a balance on the page. Displays the balance's value and
    # currency, and has buttons to edit or delete it. With JS, clicking 'edit'
    # will show a form to update the balance's value which saves via AJAX.
    #
    # @!method self.call(balance, opts = {})
    #   @param balance [Balance]
    class EditableBalance < Abroaders::Cell::Base
      include Escaped

      property :id
      property :currency_name
      property :updated_at
      property :value

      private

      def delete_btn
        link_to(
          balance_path(id),
          class: 'destroy_balance_btn btn btn-xs btn-dng12',
          data: {
            confirm: 'Are you sure? You can not undo this action',
          },
          method: :delete,
          style: 'color: #ffffff; background-color: #ff5964;',
        ) do
          '<i class="fa fa-trash"> </i> Delete'
        end
      end

      def edit_btn
        button_tag(
          class: 'edit_balance_btn btn btn-xs btn-info2',
          'data-balance-id': id,
          style: 'background-color: #35a7ff; color: #ffffff;',
        ) do
          '<i class="fa fa-pencil"> </i> Edit'
        end
      end

      def updated_at
        super.strftime('%D')
      end

      def cancel_btn
        button_tag(
          'Cancel',
          class: 'cancel_edit_balance_btn btn btn-sm btn-default',
          data: { 'balance-id': id },
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
          style: 'display:none;',
          &block
        )
      end

      def loading_spinner
        content_tag(
          :div,
          '',
          class: 'LoadingSpinner',
          style: 'float: right; top: 13px; right: 22px; display: none;',
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
          class: 'balance row editable_balance',
          id: "balance_#{id}",
          &block
        )
      end
    end
  end
end
