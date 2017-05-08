module AdminArea
  module CardProducts
    class OptionTags < Abroaders::Cell::Base
      def show
        products = CardProduct.all.map do |product|
          [CardProduct::Cell::FullName.(product, with_bank: true).(), product.id]
        end.sort_by { |p| p[0] }
        options_for_select(products)
      end
    end
  end
end
