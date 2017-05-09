class Balance < Balance.superclass
  # @!method self.call(params, options = {})
  #   @option params [Integer] id the ID of the balance to update
  #   @option params [Hash] balance the attributes of the updated balance
  class Update < Trailblazer::Operation
    step Nested(Edit)
    step Contract::Validate(key: :balance)
    step Contract::Persist()
  end
end
