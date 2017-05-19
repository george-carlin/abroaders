module Integrations::AwardWallet
  module Account
    # @!method self.call(params, options = {})
    #   @option params [Integer] id the ID of the balance to update
    #   @option params [Hash] award_wallet_account the attributes of the
    #     updated balance
    class Update < Trailblazer::Operation
      step Nested(Edit)
      step Contract::Validate(key: :award_wallet_account)
      step Contract::Persist()
    end
  end
end
