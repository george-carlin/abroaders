module PhoneNumber
  class Create < Trailblazer::Operation
    step Nested(PhoneNumber::New)
    step Contract::Validate(key: :account)
    step Contract::Persist()
  end
end
