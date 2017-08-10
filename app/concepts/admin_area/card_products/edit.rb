module AdminArea::CardProducts
  class Edit < Trailblazer::Operation
    extend Contract::DSL

    contract Form

    step Model(::CardProduct, :find_by)
    step Contract::Build()
  end
end
