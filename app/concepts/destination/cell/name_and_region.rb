class Destination < ApplicationRecord
  module Cell
    # A small span that shows (you guessed it) the name of the destination,
    # plus the name of the region in brackets. If the destination is an airport
    # it will also show the IATA code after then mae. Used while displaying
    # travel plans. New travel plans always have airports as destinations;
    # legacy data countries.
    class NameAndRegion < Trailblazer::Cell
      include ActionView::Helpers::RecordTagHelper

      private

      def html_class
        # we're using the `dom_id` method, but outputting it as the html class,
        # not id, because different travel plans might use the same
        # destinations so the IDs won't be unique on the page
        dom_id(model)
      end

      # TODO this is wrong for airports
      def name
        if model.airport?
          "#{model.city.name} (#{model.code})"
        else
          model.name
        end
      end

      def region_name
        model.region.name
      end
    end
  end
end
