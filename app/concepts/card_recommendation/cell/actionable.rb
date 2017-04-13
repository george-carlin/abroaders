class CardRecommendation < CardRecommendation.superclass
  module Cell
    class Actionable < Abroaders::Cell::Base
      include SerializeHelper

      property :id
      property :offer
      property :product

      # @param rec [CardRecommendation]
      def initialize(rec, options = {})
        raise 'must be an actionable rec' unless CardRecommendation.new(rec).actionable?
        super
      end

      private

      def find_card_btn
        link_to(
          'Find My Card',
          click_card_recommendation_path(model),
          id:     "card_recommendation_#{id}_find_card_btn",
          class:  'card_recommendation_find_card_btn btn btn-primary btn-sm',
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
        cell(DeclineForm, model)
      end

      def image
        cell(CardProduct::Cell::Image, product, size: '130x81')
      end

      def offer_description
        cell(Offer::Cell::Description, offer)
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
        ERB::Util.html_escape(serialize(model))
      end
    end
  end
end
