class TravelPlan < TravelPlan.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      option :account

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

      def other
        cell(Other, account)
      end

      # model: an Account
      class Other < Abroaders::Cell::Base
        property :home_airports
        property :regions_of_interest

        private

        def col_classes
          result = 'col-xs-12'
          result << ' col-md-6' if regions_of_interest.any?
          result
        end
      end
    end
  end
end
