module Card::Cell
  # model: a RecommendationNote.
  class Index::RecNote < Abroaders::Cell::Base
    property :created_at

    option :recommended_by # an Admin

    private

    def content
      cell(RecommendationNote::Cell::FormattedContent, model)
    end

    def timestamp
      created_at.strftime("%D %l:%M %P EST")
    end

    def recommended_by_basic
      cell(RecommendedBy, recommended_by, timestamp: timestamp)
    end

    def recommended_by_modal
      cell(RecommendedBy::Modal, recommended_by, timestamp: timestamp)
    end

    # model: Admin
    class RecommendedBy < Abroaders::Cell::Base
      property :avatar
      property :bio
      property :first_name
      property :full_name
      property :job_title

      option :timestamp

      private

      def headshot
        headshot_with_size(60)
      end

      def headshot_big
        headshot_with_size(120)
      end

      def headshot_with_size(s)
        image_tag(
          avatar.url,
          size: "#{s}x#{s}",
          class: 'img-responsive img-circle',
          alt: first_name,
        )
      end

      def job_title_text
        "#{job_title}, Abroaders"
      end

      class Modal < self
      end
    end
  end
end
