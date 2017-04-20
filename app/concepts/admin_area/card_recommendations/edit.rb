module AdminArea
  module CardRecommendations
    # Find a CardRecommenation by its ID, and prepare to edit it
    class Edit < Trailblazer::Operation
      extend Contract::DSL
      contract Form

      step :find_model!
      step Contract::Build()

      private

      def find_model!(options, params:, **)
        options['model'] = Card.recommended.find(params[:id])
      end
    end
  end
end
