class CardAccount < CardAccount.superclass
  # @!method self.call(params, options) see CardAccount::New.call;
  #   this op has the exact same method signature
  class Create < Trailblazer::Operation
    step Nested(New)
    step Contract::Validate(key: :card_account)
    success :sanity_check!
    step Contract::Persist()

    private

    # the HTML form should disable the 'closed_on' input(s) when 'closed' is
    # unchecked, so that closed_on only gets included in the params when it's
    # needed - but be defensive here anywhere.
    def sanity_check!(opts)
      contract = opts['contract.default']
      raise 'this should never happen' if !contract.closed && !contract.closed_on.nil?
    end
  end
end
