class TravelPlan < TravelPlan.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      alias collection model

      def title
        'Travel Plans'
      end

      private

      def travel_plans
        if collection.any?
          cell(TravelPlan::Cell::Summary, collection: collection, well: false).join('<hr>') { |cell| cell }
        else
          "You haven't added any travel plans yet. Click 'Add New' above to get started."
        end
      end
    end
  end
end
