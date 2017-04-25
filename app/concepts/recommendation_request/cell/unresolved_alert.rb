class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    class UnresolvedAlert < Abroaders::Cell::RecommendationAlert
      # @param account [Account] the currently logged-in account. Must have at
      #   least one unresolved rec request - error will be raiser if it doesn't
      def initialize(account, options = {})
        unresolved_reqs = account.unresolved_recommendation_requests?
        unresolved_recs = account.unresolved_card_recommendations?
        unless unresolved_reqs && !unresolved_recs
          raise ArgumentError, "#{self.class} shouldn't be rendered"
        end
        super
      end

      property :unresolved_recommendation_requests

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
