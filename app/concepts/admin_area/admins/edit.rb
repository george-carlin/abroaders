module AdminArea::Admins
  class Edit < Trailblazer::Operation
    extend Contract::DSL

    contract EditForm

    step Model(Admin, :find_by)
    step Contract::Build()
  end
end
