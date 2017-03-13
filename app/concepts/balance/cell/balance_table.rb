class Balance < Balance.superclass
  module Cell
    # An .hpanel with a table of balances for a specific person. Has a link to
    # add a new balance for the person. By default the balances are rendered
    # with the EditableBalance cell, which means their values can be updated by
    # AJAX.
    #
    # @!method self.call(person, opts = {})
    #   @param person [Person]
    #   @option opts [Boolean] use_name (false) if true the header will say
    #     "(Person name)'s points" and the link will say "Add new balance for
    #     (name)". When false, they will simply say "My points" and "Add new".
    #   @option opts [Cell] balance_cell (EditableBalance) the cell which will
    #     be used to render each individual balance.
    class BalanceTable < Abroaders::Cell::Base
      include Escaped

      property :first_name

      private

      def balance_cell
        options.fetch(:balance_cell, EditableBalance)
      end

      def balances
        if model.balances.any?
          cell(balance_cell, collection: model.balances).join('<hr>') { |c| c }
        else
          'No balances'
        end
      end

      def header_text
        if use_name?
          "#{first_name}'s points"
        else
          'My points'
        end
      end

      def link_to_add_new_balance
        text = if use_name?
                 "Add new balance for #{first_name}"
               else
                 'Add new'
               end
        link_to(
          text,
          new_person_balance_path(model),
          class: 'btn btn-primary btn-sm',
          style: 'float: right; margin-bottom: 6px;',
        )
      end

      def use_name?
        options[:use_name]
      end
    end
  end
end
