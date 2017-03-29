module AdminArea
  module CardRecommendations
    module Operation
      class Create < Trailblazer::Operation
        extend Contract::DSL

        contract do
          feature Reform::Form::Dry

          property :offer_id

          validation do
            required(:offer_id).filled(:int?)
          end
        end

        step :validate_offer_is_live!
        failure :log_offer_is_not_live!
        step :setup_person!
        step :setup_model!
        step Contract::Build()
        step Contract::Validate(key: :card_recommendation)
        step Contract::Persist()

        private

        def log_offer_is_not_live!(opts, params:, **)
          id = params[:card_recommendation][:offer_id]
          opts['errors'] = ["Couldn't find live offer with ID #{id}"]
        end

        def setup_model!(opts, person:, **)
          opts['model'] = person.card_recommendations.new
        end

        def setup_person!(opts, params:, **)
          opts['person'] = Person.find(params[:person_id])
        end

        def validate_offer_is_live!(_opts, params:, **)
          Offer.live.exists?(id: params[:card_recommendation][:offer_id])
        end
      end
    end
  end
end
