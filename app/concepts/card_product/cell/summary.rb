class CardProduct < CardProduct.superclass
  module Cell
    # @!method self.call(card_product, options = {})
    class Summary < Abroaders::Cell::Base
      property :bank_name

      private

      def image
        Image.(model, size: '130x81')
      end

      def name
        CardProduct::Cell::FullName.(model, network_in_brackets: true)
      end
    end
  end
end
