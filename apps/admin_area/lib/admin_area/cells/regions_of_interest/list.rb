module AdminArea
  module Cells
    module RegionsOfInterest
      class List < AdminArea::Cell
        def show
          content_tag :ul, regions
        end

        private

        def regions
          cell(Item, collection: model)
        end

        class Item < AdminArea::Cell
          alias region model

          property :name

          def show
            content_tag :li, name
          end
        end
      end
    end
  end
end
