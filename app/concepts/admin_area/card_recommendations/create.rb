module AdminArea
  module CardRecommendations
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
      step Contract::Validate(key: :card)
      step Wrap(Abroaders::Transaction) {
        step Contract::Persist()
        success :set_rec_request_id!
      }

      private

      def validate_offer_is_live!(params:, **)
        Offer.live.exists?(id: params[:card][:offer_id])
      end

      def log_offer_is_not_live!(opts, params:, **)
        id = params[:card][:offer_id]
        opts['errors'] = ["Couldn't find live offer with ID #{id}"]
      end

      def setup_person!(opts, params:, **)
        opts['person'] = Person.find(params[:person_id])
      end

      def setup_model!(opts, current_admin:, person:, **)
        opts['model'] = person.cards.new(
          recommended_at: Time.zone.now,
          recommended_by: current_admin,
        )
      end

      def set_rec_request_id!(model:, person:, **)
        if (req = person.unresolved_recommendation_request)
          model.update!(recommendation_request: req)
        end
      end
    end
  end
end
