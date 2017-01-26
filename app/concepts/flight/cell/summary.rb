class Flight < ApplicationRecord
  module Cell
    # A <span> that has a little pic of plane and says where the flight is from
    # and to.
    class Summary < Trailblazer::Cell
      include FontAwesome::Rails::IconHelper
      include ActionView::Helpers::RecordTagHelper

      private

      def plane_icon
        fa_icon 'plane'
      end

      def html_id
        dom_id(model)
      end

      def html_class
        dom_class(model)
      end

      def name_and_region(dest)
        cell Destination::Cell::NameAndRegion, dest
      end

      def from
        name_and_region(model.from)
      end

      def to
        name_and_region(model.to)
      end
    end
  end
end
