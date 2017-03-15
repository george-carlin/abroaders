module AdminArea
  module HomeAirports
    module Cell
      # Takes a collection of Airports and renders a basic <ul> containing
      # each airport's name and IATA code.
      #
      # Note that this will return '<ul></ul>', not an empty string,
      # if the collection is empty.
      #
      # @!method self.call(model, opts = {})
      #   @param model [Collection<Airport>]
      class List < Abroaders::Cell::Base
        def show
          content_tag :ul, items
        end

        # the cell that renders an individual list item. Sticking it in a
        # class method like this so I can easily stub it when testing.  Still
        # haven't figured out the best way to handle DI in cells. FIXME
        def self.item_cell
          Item
        end

        private

        def items
          cell(self.class.item_cell, collection: model)
        end

        # model: an Airport
        class Item < Abroaders::Cell::Base
          property :full_name

          def show
            content_tag(:li, full_name)
          end
        end
      end
    end
  end
end
