class Registration::Update < Trailblazer::Operation
  step Nested(Registration::Edit)
  step Contract::Validate(key: :account)
  step Contract::Persist()
end
