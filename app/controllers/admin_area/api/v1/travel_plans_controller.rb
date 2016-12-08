module AdminArea
  module API
    module V1
      class TravelPlansController < ApplicationController
        http_basic_authenticate_with(
          name:     'abroaders',
          password: ENV['ADMIN_API_KEY'],
        )

        def index
          render(
            json: TravelPlan::Representer.for_collection.new(TravelPlan.all).as_json,
            content_type: 'application/json',
          )
        end
      end
    end
  end
end
