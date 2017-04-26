class CardRecommendation < CardRecommendation.superclass
  module Cell
    # @param account [Account] the currently logged-in account. Must have at
    #   least one unresolved card recommendation - will raise an error if
    #   there isn't one TODO fix docs
    class UnresolvedAlert < Abroaders::Cell::RecommendationAlert
      property :unresolved_card_recommendations

      def self.show?(account)
        account.unresolved_card_recommendations?
      end

      private

      def actions
        link_to('Continue', cards_path, class: BTN_CLASSES)
      end

      def header
        'Your Card Recommendations are Ready'
      end

      def main_text
        if couples?
          people = unresolved_card_recommendations.map(&:person).uniq
          "We have posted card recommendations for #{names_for(people)}"
        else
          'We have posted your card recommendations'
        end
      end
    end
  end
end
