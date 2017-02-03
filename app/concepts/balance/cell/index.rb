class Balance < Balance.superclass
  module Cell
    class Index < Trailblazer::Cell
      class Balance < Trailblazer::Cell
        # model: a Balance
        class Buttons < Trailblazer::Cell
          property :id

          def show
            content_tag(
              :div,
              class: 'editing_balance_btn_group btn-group',
              style: 'display:none;',
            ) do
              save_btn + cancel_btn
            end
          end

          private

          def cancel_btn
            button_tag(
              'Cancel',
              class: 'cancel_edit_balance_btn btn btn-sm btn-default',
              data: { 'balance-id': id },
            )
          end

          def save_btn
            button_tag(
              'Save',
              class: 'save_balance_btn btn btn-sm btn-primary',
              data:  { 'balance-id': id },
            )
          end
        end
      end
    end
  end
end
