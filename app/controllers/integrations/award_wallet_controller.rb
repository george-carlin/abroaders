module Integrations
  class AwardWalletController < AuthenticatedUserController
    # before_action :redirect_if_already_connected!, only: [:callback, :connect]

    def callback
      run Integrations::AwardWallet::Operation::Callback do
        render cell(Integrations::AwardWallet::Cell::Callback)
        return
      end
      raise ActionController::RoutingError
    end

    def poll
      user = AwardWalletUser.find_by_aw_id!(params[:aw_id])
      # The JS will redirect them back to /balances; use the flash
      # to trigger the one-time success message on that page
      flash[:award_wallet] = 'connected' if user.loaded
      render json: {
        aw_id:  user.aw_id,
        loaded: user.loaded,
      }
    end

    def settings
      run AwardWallet::Operation::Settings do |result|
        render cell(AwardWallet::Cell::Settings, result)
      end
    end

    private

    # TODO use the operation to handle this:
    def redirect_if_already_connected!
      redirect_to(balances_path) if current_account.connected_to_award_wallet?
    end
  end
end
