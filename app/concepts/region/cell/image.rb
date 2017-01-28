class Region < Destination
  module Cell
    class Image < Trailblazer::Cell
      property :code

      def render
        image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
      end
    end
  end
end