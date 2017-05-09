class Card < Card.superclass
  module Cell
    # @!method self.call(account)
    class Index < Abroaders::Cell::Base
      property :eligible_people
      property :people
      property :actionable_card_recommendations?

      def show
        card_recommendations.show + card_accounts.show
      end

      def title
        'My Cards'
      end

      private

      def card_accounts
        cell(Card::Cell::Index::CardAccounts, model)
      end

      def card_recommendations
        cell(Cell::Index::CardRecommendations, model)
      end
    end
  end
end
