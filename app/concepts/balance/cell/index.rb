class Balance < Balance.superclass
  module Cell
    # model: the result of Balance::Operations::Index
    # result must have these keys defined:
    #   account: the current account
    #   people_with_balances:
    #       a hash with the account's people as the keys, and the person's
    #       balances as the values.
    class Index < Trailblazer::Cell
      alias result model

      private

      def account
        result['account']
      end

      def balances_for_person(person, balances)
        cell(BalancesForPerson, person, account: account, balances: balances)
      end

      def link_to_add_new_balance
        link_to(
          'Add new',
          new_person_balance_path(account.owner),
          class: 'btn btn-primary btn-sm',
          style: 'float: right; margin-bottom: 6px;',
        )
      end

      def people_with_balances
        result['people_with_balances']
      end

      # model: a Person
      # options:
      #   balances: collection of the person's Balances (may be empty)
      #   account:  the current account
      class BalancesForPerson < Trailblazer::Cell
        include Escaped

        property :first_name

        private

        def account
          options.fetch(:account)
        end

        def balances
          collection = options.fetch(:balances)
          cell(Balance::Cell::Index::EditableBalance, collection: collection)
        end

        def link_to_add_new_balance
          link_to(
            "Add new balance for #{first_name}",
            new_person_balance_path(model),
          )
        end
      end

      # a single balance on the page, displaying its value and currency, and
      # buttons to edit or delete it. When you click 'edit' a form appears (via
      # JS) and you can update the balance's value via AJAX
      #
      # model: a Balance
      class EditableBalance < Trailblazer::Cell
        include BootstrapOverrides

        property :id

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
          form_for model, data: { remote: true }, &block
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

        def value
          cell(Balance::Cell::Value, model)
        end

        def value_field(form_builder)
          form_builder.number_field(
            :value,
            class: 'balance_value_editing',
            style: 'display: none; height: 30px;',
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
end
