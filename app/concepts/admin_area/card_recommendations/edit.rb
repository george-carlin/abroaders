module AdminArea
  module CardRecommendations
    # Find a CardRecommenation by its ID, and prepare to edit it.
    #
    # This page is very crude and basic, but we don't need a super-complicated
    # thing for now - we just needed to throw something up quickly. The form
    # object provides some basic validations, but there are too many
    # permutations of possible values for it to be worth going overboard making
    # sure we cover every possible way data might be 'invalid'. The onus is on
    # the admins to make sure they don't save nonsensical data.
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
