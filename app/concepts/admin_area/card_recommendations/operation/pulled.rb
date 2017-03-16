module AdminArea
  module CardRecommendations
    module Operation
      class Pulled < Trailblazer::Operation
        success :setup_data

        private

        def setup_data(opts, params:, **)
          opts['person']     = Person.find(params.fetch(:person_id))
          opts['account']    = opts['person'].account
          opts['collection'] = opts['person'].card_recommendations.pulled
        end
      end
    end
  end
end
