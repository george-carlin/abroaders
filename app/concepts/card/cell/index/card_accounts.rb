class Card < Card.superclass
  module Cell
    class Index < Index.superclass
      # Displays card accounts (i.e. any card which has an 'opened_at' date)
      #
      # @!method self.call(account)
      #
      # options:
      #   account: the account itself.
      #   card_cell: the DI'ed cell class that will be used to render each
      #       individual card. Defaults to Card::Cell::BasicCard
      class CardAccounts < Abroaders::Cell::Base
        alias account model

        property :card_accounts

        private

        def card_accounts_for_each_person
          cell(
            ForPerson, collection: account.people, use_name: account.couples?,
          ).join('<hr>') { |cell| cell }
        end

        def btn_to_add_new
          link_to(
            'Add New',
            new_card_path,
            class: 'btn btn-primary btn-sm',
            style: 'float:right; margin-top: 6px',
          )
        end

        # @!method self.call(person, opts = {})
        #   @option opts [Boolean] use_name whether to use the person's name,
        #     as opposed to referring to them as 'you'
        class ForPerson < Abroaders::Cell::Base
          include Escaped

          property :card_accounts
          property :first_name
          property :type

          option :use_name

          def show
            content_tag :div, id: "#{type}_card_accounts" do
              if card_accounts.any?
                "<h3>#{first_name}'s cards</h4>" <<
                  cell(Card::Cell::BasicCard, collection: card_accounts, editable: true).()
              else
                "<p>#{first_name} has no cards</p>"
              end
            end
          end
        end
      end
    end
  end
end
