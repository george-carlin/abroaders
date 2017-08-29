module AdminArea
  module People
    module Cell
      class Show < Show.superclass
        # The rec notes for a person. (Actually rec notes are associated with
        # the account, not the specific person, but we're showing the notes
        # on a page that's specific to the person.)
        #
        # If the person has no notes, the cell renders "". If there are some,
        # returns them in a list with an h3 header.
        #
        # @!method self.call(account, options = {})
        #   @param account [Account]
        class RecommendationNotes < Abroaders::Cell::Base
          property :recommendation_notes

          def show
            return '' if recommendation_notes.none?
            notes = recommendation_notes.sort_by(&:created_at).reverse
            list  = cell(ListItem, collection: notes, person: model)
            "<h3>Recommendation Notes</h3>#{list}"
          end

          class ListItem < Abroaders::Cell::Base
            property :content
            property :created_at

            option :person

            private

            def link_to_edit
              link_to 'Edit', edit_admin_recommendation_note_path(model, person_id: person.id)
            end
          end
        end
      end
    end
  end
end
