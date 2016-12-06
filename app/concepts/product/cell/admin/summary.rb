module Product::Cell::Admin
  class Summary < Trailblazer::Cell
    private

    def product
      @product ||= Product::Cell.(model)
    end
  end
end
