class Destination < Destination.superclass
  module Cell
    # A small span that shows (you guessed it) the name of the destination,
    # plus the name of the region in brackets. If the destination is an airport
    # it will also show the IATA code after then mae. Used while displaying
    # travel plans. New travel plans always have airports as destinations;
    # legacy data countries.
    class NameAndRegion < Abroaders::Cell::Base
      private

      def html_class
        # the same destination may be rendered more than once on the page (if
        # there's more than one TravelPlan that goes to or from it), so this
        # string can't be used as the HTML ID because it might not be unique.
        "#{model.model_name.param_key}_#{model.id}"
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
