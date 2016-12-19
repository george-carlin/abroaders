module AdminArea
  module Cells
    module RegionsOfInterest
      class List < Trailblazer::Cell
        # TODO reduce the need for all this boilerplate:
        def self.view_name
          'regions_of_interest/list'
        end

        def self.prefixes
          ['apps/admin_area/lib/admin_area/views']
        end

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
