class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    # @param account [Account] the currently logged-in account. Must have at
    #   least one unresolved rec request - error will be raised if it doesn't TODO fix docs
    class UnresolvedAlert < Abroaders::Cell::RecommendationAlert
      property :unresolved_recommendation_requests

      def self.can_handle_account?(account)
        unresolved_reqs = account.unresolved_recommendation_requests?
        unresolved_recs = account.unresolved_card_recommendations?
        unresolved_reqs && !unresolved_recs
      end

      private

      def header
        if couples?
          people = unresolved_recommendation_requests.map(&:person).uniq
          "Abroaders is Working on Card Recommendations for #{names_for(people)}"
        else
          'Abroaders is Working on Your Card Recommendations'
        end
      end

      def main_text
        'They should be ready in 1-2 business days'
      end
    end
  end
end
