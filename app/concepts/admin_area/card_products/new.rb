module AdminArea::CardProducts
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract Form

    step Model(::CardProduct, :new)
    step Contract::Build()
  end
end
