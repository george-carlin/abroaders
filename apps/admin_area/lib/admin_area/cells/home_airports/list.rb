module AdminArea
  module Cells
    module HomeAirports
      class List < AdminArea::Cell
        def show
          content_tag :ul, airports
        end

        private

        def airports
          cell(Airport, collection: model)
        end

        class Airport < AdminArea::Cell
          alias airport model

          property :code
          property :name

          def show
            content_tag :li, "#{name} (#{code})"
          end
        end
      end
    end
  end
end
