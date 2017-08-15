module Card::Cell
  # model: a RecommendationNote.
  class Index::RecNote < Abroaders::Cell::Base
    include Escaped

    property :created_at
    property :admin

    private

    %w[full_name first_name job_title].each do |method|
      define_method "admin_#{method}" do
        escape!(admin.send(method))
      end
    end

    def content
      cell(RecommendationNote::Cell::FormattedContent, model)
    end

    def headshot
      cell(Headshot, admin).show(60)
    end

    def link_to_see_bio
      return '' if admin.bio.blank?
      link_to(
        'see bio',
        '#',
        style: 'color: #35a7ff',
        data: { toggle: 'modal', target: '#rec_recommended_by_bio' },
      )
    end

    def bio_modal
      return '' if admin.bio.blank?
      cell(BioModal, admin, timestamp: timestamp)
    end

    def timestamp
      created_at.in_time_zone('EST').strftime("%D %l:%M %P EST")
    end

    # model: Admin
    class BioModal < Abroaders::Cell::Base
      include Escaped

      property :full_name
      property :job_title

      option :timestamp

      private

      def bio # don't use property :bio because we don't want it to be escaped
        model.bio
      end

      def headshot
        cell(Headshot, model).show(120)
      end

      def job_title
        return '' if super.blank?
        "<p style='color:#ffffff'>#{super}, Abroaders</p>"
      end
    end

    # model: admin
    class Headshot < Abroaders::Cell::Base
      include Escaped

      property :avatar
      property :first_name

      def show(width)
        image_tag(
          avatar.url,
          size: "#{width}x#{width}",
          class: 'img-responsive center-block img-circle',
          alt: first_name,
        )
      end

      private

      def headshot
        cell(Headshot, admin).show(120)
      end
    end
  end
end
