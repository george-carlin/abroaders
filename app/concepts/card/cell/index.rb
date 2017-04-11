class Card < Card.superclass
  module Cell
    class Index < Abroaders::Cell::Base
      property :eligible_people
      property :people
      property :unresolved_card_recommendations?
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

      # @!method self.call(account, options = {})
      class CardRecommendations < Abroaders::Cell::Base
        property :people

        def show
          content_tag :div, id: 'card_recommendations' do
            cell(ForPerson, collection: people)
          end
        end

        # @!method self.call(person, options = {})
        class ForPerson < Abroaders::Cell::Base
          include Escaped

          property :account
          property :first_name
          property :type
          property :unresolved_card_recommendations

          def show
            content_tag :div, id: "#{type}_card_recommendations" do
              header + recommendations
            end
          end

          private

          def header
            return '' unless account.couples?
            "<h3>#{first_name}'s Recommendations</h3>"
          end

          def recommendations
            if unresolved_card_recommendations.any?
              cell(
                CardRecommendation::Cell::UnresolvedRec,
                collection: unresolved_card_recommendations,
              ).join('<hr>') { |c| c }
            else
              "No recommendations for #{first_name}"
            end
          end
        end
      end
    end
  end
end
