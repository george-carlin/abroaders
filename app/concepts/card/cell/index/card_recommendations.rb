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
          content_tag :div, id: 'card_recommendations' do
            cell(ForPerson, collection: people).join('<hr>')
          end
        end

        def note
          return '' if recommendation_note.nil?
          cell(
            RecNote,
            recommendation_note,
            recommended_by: recommended_by,
          )
        end

        # We're not saving which admin sent the rec *note*, only which admin
        # sent the individual recs. Eventually we'll want a more complicated
        # rec note system entirely. For now, use the imperfect solution of
        # assuming that all recs were recommended by whoever recommended the
        # *most recent* rec.
        #
        # If the Card is a recommendation, then recommended_by should not be
        # nil.  (When I added the recommended_by column, I updated all legacy
        # recs to say they were recommended by Erik.) So if this line returns
        # nil, something's gone wrong:
        def recommended_by
          rec = actionable_card_recommendations.max_by(&:recommended_at)
          rec.recommended_by
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
              ).join('<hr>')
            else
              "No recommendations for #{first_name}"
            end
          end
        end
      end
    end
  end
end
