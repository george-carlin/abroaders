module Integrations
  module AwardWallet
    class Sync < Trailblazer::Operation
      self['refresh_job'] = User::Refresh::Job

      success :raise_if_not_connected_to_award_wallet!
      success :enqueue_job
      success :update_syncing_status

      private

      def raise_if_not_connected_to_award_wallet!(current_account:, **)
        raise 'Not connected to AwardWallet' unless current_account.award_wallet?
      end

      def enqueue_job(opts, current_account:, **)
        aw_user = current_account.award_wallet_user
        unless aw_user.syncing? # There'll already be an enqueued job
          opts['refresh_job'].perform_later('id' => aw_user.id)
        end
      end

      def update_syncing_status(current_account:, **)
        aw_user = current_account.award_wallet_user
        aw_user.update!(syncing: true) unless aw_user.syncing?
      end
    end
  end
end
