class Recommendation::Cell < Trailblazer::Cell
  class Note < self
    property :content
    property :created_at

    private

    def headshot
      image_tag 'erik.png', size: '60x60', class: 'img-responsive img-circle', alt: 'Erik'
    end

    def headshot_big
      image_tag 'erik.png', size: '120x120', class: 'img-responsive img-circle', alt: 'Erik'
    end

    def note
      auto_link(simple_format(super))
    end

    def timestamp
      created_at.strftime("%D %l:%M %P EST")
    end
  end
end
