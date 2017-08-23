module Integrations
  class AwardWalletController < AuthenticatedUserController
    onboard :award_wallet, with: [:survey, :save_survey]

    def callback
      result = run Integrations::AwardWallet::Callback
      if result.success?
        render cell(Integrations::AwardWallet::Cell::Callback)
      else
        case result['error']
        when 'not found' then raise ActiveRecord::RecordNotFound # 404
        when 'already loaded' then redirect_to integrations_award_wallet_settings_path
        # the user clicked 'deny' on AwardWallet.com:
        when 'permission denied' then redirect_to balances_path
        end
      end
    end

    def poll
      user = AwardWalletUser.find_by_aw_id!(params[:aw_id])
      # The JS will redirect them back to /balances; use the flash
      # to trigger the one-time success message on that page
      flash[:award_wallet_just_connected] = 'connected' if user.loaded
      render json: {
        aw_id:  user.aw_id,
        loaded: user.loaded,
      }
    end

    def settings
      run AwardWallet::Settings do |result|
        render cell(AwardWallet::Cell::Settings, result)
        return
      end
      redirect_to balances_path
    end

    def survey
    end

    def save_survey
    end

    def sync
      run Integrations::AwardWallet::Sync
      render cell(Integrations::AwardWallet::Cell::Sync)
    end

    def syncing
      user = current_account.award_wallet_user || raise('no award wallet user')
      # The JS will redirect them back to /balances; use the flash
      # to trigger the one-time success message on that page
      flash[:success] = 'Refreshed AwardWallet data!' if user.syncing
      render json: {
        aw_id: user.aw_id,
        syncing: user.syncing,
      }
    end

    private

    def redirect_if_already_connected!
      redirect_to(balances_path) if current_account.award_wallet?
    end
  end
end
