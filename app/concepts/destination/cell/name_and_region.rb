class Destination < Destination.superclass
  module Cell
    # A small span that shows (you guessed it) the name of the destination,
    # plus the name of the region in brackets. If the destination is an airport
    # it will also show the IATA code after the name (although the logic for
    # that lives within the Destination classes themselves, in the #full_name
    # method.) Used while displaying travel plans.o
    #
    # @!self.method(airport_or_country, options = {})
    #   @param airport_or_country [Destination] new travel plans are always
    #     to/from a specific airport. Legacy data includes travel plans that are
    #     to/from a country rather than an airport.
    class NameAndRegion < Abroaders::Cell::Base
      property :full_name
      property :region_name

      private

      def html_class
        # we're using the `dom_id` method, but outputting it as the html class,
        # not id, because different travel plans might use the same
        # destinations so the IDs won't be unique on the page
        dom_id(model)
      end
    end
  end
end
