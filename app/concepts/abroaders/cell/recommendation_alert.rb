module Abroaders
  module Cell
    class RecommendationAlert < Abroaders::Cell::Base
      # @param account [Account] the currently logged-in account
      def initialize(model, options = {})
        raise 'model must be an Account' unless model.is_a?(Account)
        super
      end

      include ::Cell::Builder

      builds do |account|
        if account.unresolved_card_recommendations?
          CardRecommendation::Cell::UnresolvedAlert
        elsif account.unresolved_recommendation_requests?
          RecommendationRequest::Cell::UnresolvedAlert
        else
          RecommendationRequest::Cell::CallToAction
        end
      end

      BTN_CLASSES = 'btn btn-success'.freeze # TODO lg?

      property :couples?

      def show # use the same view for all subclasses
        <<-HTML
          <div class="alert alert-info">
            #{header}

            <p style="font-size: 14px;">
              #{main_text}
            </p>

            #{actions}
          </div>
        HTML
      end

      private

      def actions
        ''
      end

      def names_for(people)
        escape(people.map(&:first_name).join(' and '))
      end
    end
  end
end
