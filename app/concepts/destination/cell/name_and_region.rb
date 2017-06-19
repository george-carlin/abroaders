class Destination < Destination.superclass
  module Cell
    # A small span that shows (you guessed it) the name of the destination,
    # plus the name of the region in brackets. If the destination is an airport
    # it will also show the IATA code after the name (although the logic for
    # that lives within the Destination classes themselves, in the #full_name
    # method.) Used while displaying travel plans.o
    #
    # @!method self.call(airport_or_country, options = {})
    #   @param airport_or_country [Destination] new travel plans are always
    #     to/from a specific airport. Legacy data includes travel plans that are
    #     to/from a country rather than an airport.
    class NameAndRegion < Abroaders::Cell::Base
      property :full_name
      property :region_name

      private

      def html_class
        # the same destination may be rendered more than once on the page (if
        # there's more than one TravelPlan that goes to or from it), so this
        # string can't be used as the HTML ID because it might not be unique.
        "#{model.model_name.param_key}_#{model.id}"
      end
    end
  end
end
