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

      step :offer_recommendable?
      failure :log_offer_not_recommendable, fail_fast: true
      step :setup_person!
      step :setup_model!
      step Contract::Build()
      step Contract::Validate(key: :card)
      step Contract::Persist()

      private

      def offer_recommendable?(params:, **)
        Offer.recommendable.exists?(id: params[:card_recommendation][:offer_id])
      end

      def log_offer_not_recommendable(opts, params:, **)
        id = params[:card_recommendation][:offer_id]
        opts['error'] = "Couldn't find recommendable offer with ID #{id}"
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
    end
  end
end
