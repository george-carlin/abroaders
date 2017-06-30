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
      step Contract::Persist()

      private

      def log_offer_is_not_live!(opts, params:, **)
        id = params[:card][:offer_id]
        opts['errors'] = ["Couldn't find live offer with ID #{id}"]
      end

      def setup_model!(opts, admin:, person:, **)
        opts['model'] = person.cards.new(
          recommended_at: Time.zone.now,
          recommended_by: admin,
        )
      end

      def setup_person!(opts, params:, **)
        opts['person'] = Person.find(params[:person_id])
      end

      def validate_offer_is_live!(_opts, params:, **)
        Offer.live.exists?(id: params[:card][:offer_id])
      end
    end
  end
end
