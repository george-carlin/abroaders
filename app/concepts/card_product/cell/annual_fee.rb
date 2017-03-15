class CardProduct < CardProduct.superclass
  module Cell
    # Takes a CardProduct, returns its annual fee in the format $X.XX.
    #
    # p = CardProduct.new(annual_fee_cents: 1234)
    # CardProduct::Cell::AnnualFee.(p).() # => '$1,234.00'
    class AnnualFee < Abroaders::Cell::Base
      property :annual_fee_cents

      def show
        number_to_currency(annual_fee_cents / 100)
      end
    end
  end
end
