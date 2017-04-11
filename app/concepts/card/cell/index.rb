class Card < Card.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      property :eligible_people
      property :people
      property :actionable_card_recommendations?
      property :recommendation_note

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

      def note
        return '' if recommendation_note.nil?
        cell(CardRecommendation::Cell::Note, recommendation_note)
      end
    end
  end
end
