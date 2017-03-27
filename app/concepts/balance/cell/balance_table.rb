class Balance < Balance.superclass
  module Cell
    # An .hpanel with a table of balances for a specific person. Has a link to
    # add a new balance for the person. By default the balances are rendered
    # with the EditableBalance cell, which means their values can be updated by
    # AJAX.
    #
    # If the person belongs to a couples account, the header will say "(Person
    # name)'s points" and the link will say "Add new balance for (name)". If
    # it's a solo account, they will simply say "My points" and "Add new".
    #
    # @!method self.call(person, opts = {})
    #   @param person [Person]
    class BalanceTable < Abroaders::Cell::Base
      include ::Cell::Builder
      include Escaped

      builds do |person|
        person.account.couples? ? Couples : Solo
      end

      property :award_wallet_accounts
      property :balances
      property :first_name

      def show
        render 'balance_table'
      end

      private

      def rows
        items = (award_wallet_accounts + balances).map { |i| LoyaltyAccount.build(i) }
        # items = balances.map { |i| LoyaltyAccount.build(i) }
        cell(LoyaltyAccount::Cell::Editable, collection: items).join('<hr>') { |c| c }
      end

      def link_to_add_new_balance
        link_to(
          new_person_balance_path(model),
          class: 'btn btn-success btn-xs',
        ) do
          "<i class='fa fa-plus'> </i> #{add_new}"
        end
      end

      class Couples < self
        def add_new
          "Add new balance for #{first_name}"
        end

        def header_text
          "#{first_name}'s points"
        end
      end

      class Solo < self
        def add_new
          'Add new'
        end

        def header_text
          'My points'
        end
      end
    end
  end
end
