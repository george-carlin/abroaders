class Balance < Balance.superclass
  # @!method self.call(params, options = {})
  #   @option params [Hash] balance the attributes of the new balance
  class New < Trailblazer::Operation
    extend Contract::DSL
    contract Form

    step Model(Balance, :new)
    step Contract::Build()
  end
end
