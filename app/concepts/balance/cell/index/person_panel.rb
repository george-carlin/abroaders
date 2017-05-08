module Balance::Cell
  class Index < Index.superclass
    # An .hpanel with a table of balances for a specific person. Has a link to
    # add a new balance for the person. By default the balances are rendered
    # with the EditableBalance cell, which means their values can be updated by
    # AJAX.
    #
    # If the person belongs to a couples account, the header will say "(Person
    # name)'s points". If it's a solo account, it will simply say "My points".
    #
    # This cell is rendered on balances#index, once for each person on the
    # account
    #
    # @!method self.call(person, opts = {})
    #   @param person [Person]
    class PersonPanel < Abroaders::Cell::Base
      include ::Cell::Builder
      include Escaped

      builds do |person|
        person.account.couples? ? Couples : Solo
      end

      property :first_name
      property :loyalty_accounts

      def show
        render 'balance_table'
      end

      private

      def link_to_add_new_balance
        link_to(
          new_person_balance_path(model),
          class: 'btn btn-success btn-xs',
        ) do
          '<i class="fa fa-plus"> </i> Add new'
        end
      end

      def rows
        if loyalty_accounts.any?
          cell(LoyaltyAccount::Cell::Editable, collection: loyalty_accounts).join('<hr>')
        else
          'No points balances'
        end
      end

      class Couples < self
        def header_text
          "#{first_name}'s points"
        end
      end

      class Solo < self
        def header_text
          'My points'
        end
      end
    end
  end
end
