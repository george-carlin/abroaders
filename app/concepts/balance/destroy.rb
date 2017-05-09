class Balance < Balance.superclass
  # @!method self.call(params, options = {})
  #   @option params [Integer] id the ID of the Balance that will be destroyed
  class Destroy < Trailblazer::Operation
    step :setup_model!
    step :destroy!
    failure :raise_error!

    private

    def setup_model!(opts, params:, account:, **)
      opts['model'] = account.balances.find(params[:id])
    end

    def destroy!(_opts, model:, **)
      model.destroy!
    end

    def raise_error!(*)
      raise 'an unknown error occurred' # this should never happen
    end
  end
end
