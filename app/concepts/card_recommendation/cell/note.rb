class CardRecommendation
  module Cell
    # model: a RecommendationNote.
    class Note < Abroaders::Cell::Base
      property :created_at

      private

      def content
        cell(RecommendationNote::Cell::FormattedContent, model)
      end

      def headshot
        image_tag 'erik.png', size: '60x60', class: 'img-responsive img-circle', alt: 'Erik'
      end

      def headshot_big
        image_tag 'erik.png', size: '120x120', class: 'img-responsive img-circle', alt: 'Erik'
      end

      def timestamp
        created_at.strftime("%D %l:%M %P EST")
      end
    end
  end
end
