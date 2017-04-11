class Card < Card.superclass
  module Cell
    class Index < Index.superclass
      # Displays card accounts (i.e. any card which has an 'opened_on' date),
      # grouped by the person they belong to.
      #
      # @!method self.call(account)
      #   @param account [Account]
      class CardAccounts < Abroaders::Cell::Base
        property :card_accounts
        property :couples?
        property :people

        private

        def card_accounts_for_each_person
          cell(ForPerson, collection: people).join('<hr>') { |c| c }
        end

        def btn_to_add_new
          link_to(
            'Add New',
            new_card_account_path,
            class: 'btn btn-primary btn-sm',
            style: 'float:right; margin-top: 6px',
          )
        end

        # @!method self.call(person, opts = {})
        class ForPerson < Abroaders::Cell::Base
          include Escaped

          property :card_accounts
          property :first_name
          property :partner?
          property :type

          def show
            content_tag :div, id: "#{type}_card_accounts" do
              if card_accounts.any?
                collection = cell(self.class.row_class, collection: card_accounts, editable: true)
                "<h3>#{first_name}'s cards</h4>" <<
                  collection.join('<hr>') { |c| c }
              else
                "<p>#{first_name} has no cards</p>"
              end
            end
          end

          def self.row_class
            CardAccount::Cell::Row
          end
        end
      end
    end
  end
end
