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

        def btn_to_add_new
          link_to(
            new_card_account_path,
            class: 'btn btn-success btn-xs',
          ) do
            "#{fa_icon('plus')} Add New"
          end
        end

        def card_accounts_for_each_person
          sorted_people = people.sort_by(&:type).reverse # owner first
          cell(ForPerson, collection: sorted_people).join('<hr>')
        end

        # @!method self.call(person, opts = {})
        class ForPerson < Abroaders::Cell::Base
          include ::Cell::Builder
          include Escaped

          builds { |person| person.partner? ? Couples : self }

          property :card_accounts
          property :first_name
          property :partner?
          property :type

          def show
            content_tag :div, id: "#{type}_card_accounts" do
              if card_accounts.any?
                collection = cell(self.class.row_class, collection: card_accounts, editable: true)
                header << collection.join('<hr>')
              else
                "<p>#{you_have} no cards</p>"
              end
            end
          end

          def self.row_class
            CardAccount::Cell::Row
          end

          private

          def header
            ''
          end

          def you_have
            "You have"
          end

          class Couples < self
            def header
              "<h3>#{first_name}'s cards</h4>"
            end

            def you_have
              "#{first_name} has"
            end
          end
        end
      end
    end
  end
end
