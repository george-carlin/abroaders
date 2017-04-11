class Card < Card.superclass
  module Cell
    class Index < Index.superclass
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
          property :actionable_card_recommendations

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
