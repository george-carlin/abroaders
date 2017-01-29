module AdminArea
  module CardProduct
    module Cell
      class Summary < Trailblazer::Cell
        private

        def product
          @product ||= ::CardProduct::Cell.(model)
        end
      end
    end
  end
end
