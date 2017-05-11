class CardRecommendation < CardRecommendation.superclass
  module Cell
    class Actionable < Abroaders::Cell::Base
      include Escaped

      property :id
      property :applied?
      property :bank_name
      property :card_product
      property :offer

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
        cell(CardProduct::Cell::Image, card_product, size: '130x81')
      end

      def offer_description
        cell(Offer::Cell::Description, offer)
      end

      def product_name
        cell(
          CardProduct::Cell::FullName,
          card_product,
          with_bank: true,
          network_in_brackets: true,
        )
      end

      def rec_as_json
        escape!(CardRecommendation::Representer.new(model).to_json)
      end
    end
  end
end
