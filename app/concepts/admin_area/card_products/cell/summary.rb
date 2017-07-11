module AdminArea
  module CardProducts
    module Cell
      # @!method self.call(card_product, options = {})
      class Summary < Abroaders::Cell::Base
        property :id
        property :bank
        property :bank_name
        property :bp
        property :currency
        property :currency_name
        property :name

        private

        def annual_fee
          cell(CardProduct::Cell::AnnualFee, model)
        end

        def image
          cell(CardProduct::Cell::Image, model, size: '130x81')
        end

        def network
          cell(CardProduct::Cell::Network, model)
        end

        def type
          cell(CardProduct::Cell::Type, model)
        end
      end
    end
  end
end
