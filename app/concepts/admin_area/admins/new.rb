module AdminArea::Admins
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract NewForm

    step Model(Admin, :new)
    step Contract::Build()
  end
end
