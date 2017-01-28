class CardProduct < ApplicationRecord
  class Cell < Trailblazer::Cell
    class Survey < Trailblazer::Cell
      autoload :Product, 'card_product/cell/survey/product'
    end
  end
end
