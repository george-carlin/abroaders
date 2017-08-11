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

      class OurProcessModal < Abroaders::Cell::Base
        private

        def compare_image
          image_tag(
            'process-compare.png',
            alt: 'Process',
            class: 'img-responsive center-block',
            size: '131x115',
          )
        end

        def recommend_image
          image_tag(
            'process-recommend.png',
            alt: 'Process',
            class: 'img-responsive center-block',
            size: '113x115',
          )
        end

        def review_image
          image_tag(
            'process-review.png',
            alt: 'Process',
            class: 'img-responsive center-block',
            size: '120x115',
          )
        end
      end
    end
  end
end
