require 'reform/form/dry'
require 'trailblazer/operation/contract'

class Balance < Balance.superclass
  module Operations
    class Create < Trailblazer::Operation
      step Nested(Operations::New)
      step Contract::Validate(key: :balance)
      step Contract::Persist()
    end
  end
end
