class TravelPlan < TravelPlan.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      def title
        'Travel Plans'
      end

      private

      def travel_plans
        if model.any?
          cell(TravelPlan::Cell::Summary, collection: model, well: false).join('<hr>')
        else
          "You haven't added any travel plans yet. Click 'Add New' above to get started."
        end
      end
    end
  end
end
