class Flight < ApplicationRecord
  module Cell
    # A <span> that has a little pic of plane and says where the flight is from
    # and to.
    #
    # model: a Flight
    class Summary < Trailblazer::Cell
      include FontAwesome::Rails::IconHelper

      property :id

      def show
        content_tag(:div, id: "flight_#{id}", class: 'flight') do
          "#{fa_icon('plane')} #{from} - #{to}"
        end
      end

      private

      def airport_name_cell
        options.fetch(:airport_name_cell, Destination::Cell::NameAndRegion)
      end

      def from
        name_and_region(model.from)
      end

      def name_and_region(dest)
        cell(airport_name_cell, dest)
      end

      def to
        name_and_region(model.to)
      end
    end
  end
end
