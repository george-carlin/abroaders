class CardProduct < ApplicationRecord
  class Cell < Trailblazer::Cell
    module Admin
      class Summary < Trailblazer::Cell
        private

        def product
          @product ||= CardProduct::Cell.(model)
        end
      end
    end
  end
end
