module AdminArea
  module People
    module Cell
      class Show < Show.superclass
        # A list of the person's card accounts, including recommendations.
        # (Eventually we'll want to split this, and show recommendations in a
        # different table)
        #
        # model: a collection of Cards. may be empty.
        #
        # options:
        #   person: the Person
        #   pulled_recs: The person's recommendations that were pulled by an
        #                admin. May be empty
        class Cards < Trailblazer::Cell
          alias collection model

          private

          def link_to_add_new
            link_to raw('&plus; Add'), new_admin_person_card_path(person)
          end

          def link_to_pulled_recs
            recs = options.fetch(:pulled_recs, [])
            if recs.any?
              link_to(
                "View #{recs.size} pulled recommendation#{'s' if recs.size > 1}",
                pulled_admin_person_card_recommendations_path(person),
              )
            end
          end

          def no_cards?
            collection.empty?
          end

          def person
            options.fetch(:person)
          end

          def table(&block)
            # When there are no cards, output the table's HTML but hide it
            # with CSS. It will be shown by JS if a card is recommended
            style = no_cards? ? 'display:none;' : ''
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
            cell(AdminArea::Cards::Cell::TableRow, collection: collection)
          end
        end
      end
    end
  end
end
