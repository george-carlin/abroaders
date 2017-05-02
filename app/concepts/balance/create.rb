require 'reform/form/dry'

class Balance < Balance.superclass
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :balance)
    step Contract::Persist()
  end
end
