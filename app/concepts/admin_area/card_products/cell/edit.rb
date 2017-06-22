module AdminArea::CardProducts
  module Cell
    # @!method self.call(card_product, options = {})
    class Edit < New
      property :id

      def show
        render 'new'
      end

      def title
        "Edit Card Product ##{id}"
      end
    end
  end
end
