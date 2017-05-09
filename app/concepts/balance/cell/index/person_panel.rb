module Balance::Cell
  class Index < Index.superclass
    # An .hpanel with a table of balances for a specific person. Has a link to
    # add a new balance for the person.
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
      include Escaped

      property :first_name
      property :loyalty_accounts
      property :partner?
      property :type

      private

      def header_text
        "#{partner? ? "#{first_name}'s" : 'My'} points"
      end

      def link_to_add_new_balance
        link_to new_person_balance_path(model), class: 'btn btn-success btn-xs' do
          '<i class="fa fa-plus"> </i> Add new'
        end
      end

      def rows
        if loyalty_accounts.any?
          cell(LoyaltyAccount::Cell::Table, loyalty_accounts)
        else
          'No points balances'
        end
      end
    end
  end
end
