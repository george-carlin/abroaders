class CardRecommendation < CardRecommendation.superclass
  module Cell
    # @!method self.call(rec)
    #   @param rec (CardRecommendation)
    class UnresolvedRec < Abroaders::Cell::Base
      include SerializeHelper

      property :id

      alias rec model

      private

      def apply_btn
        link_to(
          'Apply',
          apply_card_recommendation_path(model),
          id:     "card_recommendation_#{id}_apply_btn",
          class:  'card_recommendation_apply_btn btn btn-primary btn-sm',
          target: '_blank',
        )
      end

      def bank_name
        product.bank.name
      end

      def decline_btn
        button_tag(
          'No Thanks',
          id:     "card_recommendation_#{id}_decline_btn",
          class:  'card_recommendation_decline_btn btn btn-sm btn-primary btn-default',
        )
      end

      def decline_form
        cell(DeclineForm, rec)
      end

      def image
        cell(CardProduct::Cell::Image, product, size: '130x81')
      end

      def offer
        rec.offer
      end

      def offer_description
        cell(Offer::Cell::Description, offer)
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
