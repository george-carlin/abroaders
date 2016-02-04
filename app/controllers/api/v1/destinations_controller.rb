module API
  module V1
    class DestinationsController < APIController

      def typeahead
        render json: DestinationSearch.new(typeahead: params[:query]).results.to_json
      end

    end
  end
end
