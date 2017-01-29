module AdminArea
  module HomeAirports
    module Cell
      class List < Trailblazer::Cell
        def show
          content_tag :ul, airports
        end

        private

        def airports
          cell(Airport, collection: model)
        end

        class Airport < Trailblazer::Cell
          def show
            content_tag(:li, full_name)
          end
        end
      end
    end
  end
end
