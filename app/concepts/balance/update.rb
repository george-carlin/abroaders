class Balance < Balance.superclass
  # @!method self.call(params, options = {})
  #   @option params [Integer] id the ID of the balance to update
  #   @option params [Hash] balance the attributes of the updated balance
  class Update < Trailblazer::Operation
    extend Contract::DSL
    contract EditForm

    step :setup_model!
    step Contract::Build()
    step Contract::Validate(key: :balance)
    step Contract::Persist()

    private

    def setup_model!(opts, account:, params:, **)
      opts['model'] = account.balances.find(params[:id])
    end
  end
end
