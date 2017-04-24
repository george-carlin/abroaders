module AdminArea
  module RegionsOfInterest
    module Cell
      class List < Abroaders::Cell::Base
        def show
          content_tag :ul, regions
        end

        private

        def regions
          cell(Item, collection: model)
        end

        class Item < Abroaders::Cell::Base
          property :name

          def show
            content_tag :li, name
          end
        end
      end
    end
  end
end
