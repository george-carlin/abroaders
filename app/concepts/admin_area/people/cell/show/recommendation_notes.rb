module AdminArea
  module People
    module Cell
      class Show < Show.superclass
        # The person's rec notes. If there are no rec notes, returns "". If
        # there are some, returns them in a list, wrapped in a .hpanel
        # with an h3 header.
        #
        # model: a collection of rec notes. may be empty.
        class RecommendationNotes < Abroaders::Cell::Base
          alias collection model

          def show
            return '' if collection.empty?
            super
          end

          private

          def notes
            cell(ListItem, collection: collection)
          end

          class ListItem < Abroaders::Cell::Base
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
