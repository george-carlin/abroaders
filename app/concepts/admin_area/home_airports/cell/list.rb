module AdminArea
  module HomeAirports
    module Cell
      # Takes a collection of Airports and renders a basic <ul> containing
      # each airport's name and IATA code.
      #
      # Note that this will return '<ul></ul>', not an empty string,
      # if the collection is empty
      class List < Trailblazer::Cell
        def show
          content_tag :ul, items
        end

        private

        def items
          cell(Item, collection: model)
        end

        # model: an Airport
        class Item < Trailblazer::Cell
          property :full_name

          def show
            content_tag(:li, full_name)
          end
        end
      end
    end
  end
end
