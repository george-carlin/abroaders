module AdminArea
  module People
    module Cell
      class Show < Show.superclass
        # A list of the person's card accounts, including recommendations.
        # (Eventually we'll want to split this, and show recommendations in a
        # different table)
        #
        # @!method self.call(person, options = {})
        #   @param person [Person] make sure that unpulled_cards => product => bank
        #     is eager-loaded.
        class Cards < Abroaders::Cell::Base
          property :pulled_card_recommendations
          property :unpulled_cards

          private

          def link_to_add_new
            link_to raw('&plus; Add'), new_admin_person_card_account_path(model)
          end

          def link_to_pulled_recs
            count = pulled_card_recommendations.size
            return '' if count == 0
            link_to(
              "View #{count} pulled recommendation#{'s' if count > 1}",
              pulled_admin_person_card_recommendations_path(model),
            )
          end

          def no_cards_notice
            return '' if unpulled_cards.any?
            '<p id="admin_person_cards_none">User has no existing card accounts</p>'
          end

          def table(&block)
            # When there are no cards, output the table's HTML but hide it
            # with CSS. It will be shown by JS if a card is recommended
            style = unpulled_cards.none? ? 'display:none;' : ''
            content_tag :div, id: 'admin_person_cards', style: style do
              content_tag(
                :table,
                class: 'table table-striped tablesorter',
                id: 'admin_person_cards_table',
                &block
              )
            end
          end

          def table_rows
            cell(AdminArea::Cards::Cell::TableRow, collection: unpulled_cards)
          end
        end
      end
    end
  end
end
