module AdminArea
  module RegionsOfInterest
    module Cell
      class List < Trailblazer::Cell
        def show
          content_tag :ul, regions
        end

        private

        def regions
          cell(Item, collection: model)
        end

        class Item < Trailblazer::Cell
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
