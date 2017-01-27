class TravelPlan < ApplicationRecord
  module Cell
    class Index < Trailblazer::Cell
      alias collection model

      private

      def travel_plans
        if collection.any?
          cell(TravelPlan::Cell::Summary, collection: collection)
        else
          "You haven't added any travel plans yet. Click 'Add New' above to get started."
        end
      end
    end
  end
end
