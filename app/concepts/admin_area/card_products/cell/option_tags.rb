module AdminArea
  module CardProducts
    # For some reason, if this cell inherits from Abroaders::Cell::Base then
    # the following bug occurs:
    #
    # 1. Start the server
    # 2. Visit any page
    # 3. Change the contents of a random file (as far as I can tell any file
    #    will cause the error, but if you're struggling then one specific file
    #    I tested with is Balance::Cell::Index.
    # 4. Refresh the page twice (not once!)
    # 5. You'll get the error 'superclass mismatch for class OptionTags'
    #
    # Looks like something funky is going on with the Rails autoloader. No idea
    # why it's only happening for this class, but it's not worth investigating
    # for now. Just use Trailblazer::Cell as the superclass instead, since
    # OptionTags doesn't use any features from A::C::B.
    class OptionTags < Trailblazer::Cell
      include ActionView::Helpers::FormOptionsHelper

      def show
        products = CardProduct.all.map do |product|
          [CardProduct::Cell::FullName.(product, with_bank: true).(), product.id]
        end.sort_by { |p| p[0] }
        options_for_select(products)
      end
    end
  end
end
