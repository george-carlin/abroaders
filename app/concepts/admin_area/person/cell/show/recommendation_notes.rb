module AdminArea
  module Person
    module Cell
      class Show < Show.superclass
        # The person's rec notes. If there are no rec notes, returns "". If
        # there are some, returns them in a list, wrapped in a .hpanel
        # with an h3 header.
        #
        # model: a collection of rec notes. may be empty.
        class RecommendationNotes < Trailblazer::Cell
          alias collection model

          def show
            return '' if collection.empty?
            super
          end

          private

          def notes
            cell(ListItem, collection: collection)
          end

          class ListItem < Trailblazer::Cell
            property :created_at

            private

            def content
              cell(RecommendationNote::Cell::FormattedContent, model)
            end
          end
        end
      end
    end
  end
end
