module AdminArea::Admins
  class Update < Trailblazer::Operation
    step Nested(Edit)
    step Contract::Validate(key: :admin)
    step Contract::Persist()
  end
end
