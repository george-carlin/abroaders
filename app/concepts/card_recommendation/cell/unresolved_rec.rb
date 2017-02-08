class CardRecommendation < CardRecommendation.superclass
  module Cell
    class UnresolvedRec < Trailblazer::Cell
      include SerializeHelper

      alias rec model

      private

      def bank_name
        product.bank.name
      end

      def image
        cell(::CardProduct::Cell::Image, product, size: '130x81')
      end

      def offer
        rec.offer
      end

      def offer_description
        cell(::Offer::Cell::Description, offer)
      end

      def product
        rec.product
      end

      def product_name
        cell(
          CardProduct::Cell::FullName,
          product,
          with_bank: true,
          network_in_brackets: true,
        )
      end

      def rec_as_json
        ERB::Util.html_escape(serialize(rec))
      end
    end
  end
end
