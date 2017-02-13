require 'reform/form/dry'
require 'trailblazer/operation/contract'

class Balance < Balance.superclass
  module Operation
    class Create < Trailblazer::Operation
      step Nested(Operation::New)
      step Contract::Validate(key: :balance)
      step Contract::Persist()
    end
  end
end
