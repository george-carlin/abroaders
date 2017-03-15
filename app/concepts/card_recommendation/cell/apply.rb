class CardRecommendation
  module Cell
    class Apply < Abroaders::Cell::Base
      alias recommendation model

      property :offer
      property :product

      private

      delegate :name, to: :product, prefix: true

      def bank_name
        product.bank.name
      end

      def click_here
        link_to 'click here', offer.link, rel: 'nofollow', target: '_blank'
      end
    end
  end
end
