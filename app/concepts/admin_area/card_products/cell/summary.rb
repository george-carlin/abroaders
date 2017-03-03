module AdminArea
  module CardProducts
    module Cell
      class Summary < Trailblazer::Cell
        property :bank
        property :bp
        property :code
        property :currency
        property :name

        private

        def annual_fee
        end

        def bank_name
          bank.name
        end

        def currency_name
          currency.name
        end

        def image
          cell(CardProduct::Cell::Image, model, size: '130x81')
        end

        def network
          cell(CardProduct::Cell::AnnualFee, model)
        end

        def type
          cell(CardProduct::Cell::Type, model)
        end
      end
    end
  end
end
