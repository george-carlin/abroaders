module API
  module V1
    class AirportsController < APIController

      def index
        render json: Airport.all
      end

    end
  end
end
