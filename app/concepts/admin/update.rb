class Admin::Update < Trailblazer::Operation
  step Nested(Admin::Edit)
  step Contract::Validate(key: :admin)
  step Contract::Persist()
end
