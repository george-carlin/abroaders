class CardProduct < CardProduct.superclass
  module Cell
    # @!method self.call(card_product, options = {})
    class Summary < Abroaders::Cell::Base
      private

      def bank_name
        model.bank.name
      end

      def image
        Image.(model, size: '130x81')
      end

      def name
        CardProduct::Cell::FullName.(model, network_in_brackets: true)
      end
    end
  end
end
