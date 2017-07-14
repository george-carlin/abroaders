module AdminArea::Admins
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :admin)
    step Contract::Persist()
  end
end
