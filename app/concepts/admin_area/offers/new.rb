module AdminArea
  module Offers
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract Offers::Form

      step :setup_card_product
      step :setup_model
      step Contract::Build()

      private

      def setup_card_product(opts, params:, **)
        id = params.fetch(:card_product_id)
        opts['card_product'] = CardProduct.find(id)
      end

      def setup_model(opts, card_product:, **)
        opts['model'] = card_product.offers.new
      end
    end
  end
end
