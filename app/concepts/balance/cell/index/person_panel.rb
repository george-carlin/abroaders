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
      include ::Cell::Builder
      include Escaped

      builds do |person|
        AwardWallet if person.award_wallet?
      end

      property :first_name
      property :loyalty_accounts
      property :partner?
      property :type

      def show # use same template for all subclasses:
        render 'index/person_panel'
      end

      private

      def header_text
        "#{partner? ? "#{first_name}'s" : 'My'} points"
      end

      def link_to_add_new_balance
        link_to new_person_balance_path(model), class: 'btn btn-success btn-xs' do
          link_to_add_new_balance_text
        end
      end

      def link_to_add_new_balance_text
        '<i class="fa fa-plus"> </i> Add new'
      end

      def new_balance_modal
        ''
      end

      def rows
        if loyalty_accounts.any?
          cell(LoyaltyAccount::Cell::Table, loyalty_accounts)
        else
          'No points balances'
        end
      end

      class AwardWallet < self
        property :id

        private

        def modal_id
          "new_balance_modal_person_#{id}"
        end

        def link_to_add_new_balance
          button_tag(
            class: 'btn btn-success btn-xs',
            'data-toggle': 'modal',
            'data-target': "##{modal_id}",
          ) do
            link_to_add_new_balance_text
          end
        end

        def new_balance_modal
          cell(
            Abroaders::Cell::ChoiceModal,
            [
              {
                link_text: 'Add a new balance on Abroaders',
                link_href: new_person_balance_path(model),
                text: 'This balance will not update automatically',
              },
              {
                link_text: 'Add a new balance on AwardWallet',
                link_href: new_person_balance_path(model),
                text: 'This balance will automatically track your points balance',
              },
            ],
            id: modal_id,
          )
        end
      end
    end
  end
end
