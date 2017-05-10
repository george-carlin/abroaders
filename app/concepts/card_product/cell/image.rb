class CardProduct < CardProduct.superclass
  module Cell
    # Takes a CardProduct and returns an <img> tag for the product's image.
    #
    # options: 'size'. Default '180x114'
    class Image < Abroaders::Cell::Base
      property :image

      DEFAULT_SIZE = '180x114'.freeze

      def show
        image_tag(url, size: options.fetch(:size, DEFAULT_SIZE))
      end

      private

      def url
        image[:medium].url
      end
    end
  end
end
