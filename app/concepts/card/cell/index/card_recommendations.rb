class Card < Card.superclass
  module Cell
    class Index < Index.superclass
      # Shows the user's ACTIONABLE card recommendations (i.e. the ones for
      # which they should see the application survey). If the user doesn't have
      # any actionable recommendations, returns an empty string.
      #
      # @!method self.call(account, options = {})
      class CardRecommendations < Abroaders::Cell::Base
        property :actionable_card_recommendations
        property :actionable_card_recommendations?
        property :people
        property :recommendation_note

        def show
          return '' unless actionable_card_recommendations?
          render
        end

        private

        def card_recommendations_for_each_person
          cell(ForPerson, collection: people)
        end

        def note
          return '' if recommendation_note.nil?
          cell(CardRecommendation::Cell::Note, recommendation_note)
        end

        # @!method self.call(person, options = {})
        class ForPerson < Abroaders::Cell::Base
          include Escaped

          property :actionable_card_recommendations
          property :first_name
          property :partner?
          property :type

          def show
            content_tag :div, id: "#{type}_card_recommendations" do
              header + recommendations
            end
          end

          private

          def header
            return '' unless partner?
            "<h3>#{first_name}'s Recommendations</h3>"
          end

          def recommendations
            if actionable_card_recommendations.any?
              cell(
                CardRecommendation::Cell::Actionable,
                collection: actionable_card_recommendations,
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
