module AdminArea
  module Offers
    # With no 'duplicate_id' param, this op functions like a normal 'new' op
    # and initializes the form with its normal defaults.
    #
    # With a 'duplicate_id' param, the op finds the offer with that ID and
    # initializes the form with the same attributes as the offer that will be
    # duplicated (minus the link, which must be manually filled in every time).
    #
    # Note that saving the form will create a new offer, rather than update the
    # existing offer.
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract Offers::Form

      step :setup_card_product
      step :setup_model
      step Contract::Build()

      private

      def setup_card_product(opts, params:, **)
        id = params.fetch(:card_product_id)
        opts['card_product'] = CardProduct.includes(:currency).find(id)
      end

      def setup_model(opts, card_product:, params: nil, **)
        offer = if params[:duplicate_id].present?
                  original = card_product.offers.find(params[:duplicate_id])
                  # pre-fill all attributes except the new link:
                  original.dup.tap { |o| o.assign_attributes(link: nil) }
                else
                  card_product.offers.new
                end
        opts['model'] = offer
      end
    end
  end
end
