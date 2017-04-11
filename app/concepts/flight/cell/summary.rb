class Flight < Flight.superclass
  module Cell
    # A `<span>` that has a little pic of plane and says where the flight is from
    # and to.
    #
    # @!method self.call(model, opts = {})
    #   @param model [Flight]
    class Summary < Abroaders::Cell::Base
      property :id

      def show
        content_tag(:div, id: "flight_#{id}", class: 'flight') do
          "#{fa_icon('plane')} #{from} - #{to}"
        end
      end

      def self.airport_name_cell
        Destination::Cell::NameAndRegion
      end

      private

      def from
        name_and_region(model.from)
      end

      def name_and_region(dest)
        cell(self.class.airport_name_cell, dest)
      end

      def to
        name_and_region(model.to)
      end
    end
  end
end
