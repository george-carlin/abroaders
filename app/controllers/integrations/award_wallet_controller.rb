module Integrations
  class AwardWalletController < AuthenticatedUserController
    def settings
      run AwardWallet::Operation::Settings do |result|
        render cell(AwardWallet::Cell::Settings, result)
        return
      end
      redirect_to balances_path
    end
  end
end
