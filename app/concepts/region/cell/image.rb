class Region < Destination
  module Cell
    class Image < Abroaders::Cell::Base
      property :code

      def show
        image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
      end
    end
  end
end
