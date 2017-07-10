module Integrations
  module AwardWallet
    class Settings < Trailblazer::Operation
      step :set_user
      step :user_loaded?
      failure :log_not_connected
      step :set_owners_with_accounts
      step :eager_load_people

      private

      def set_user(opts, current_account:, **)
        opts['user'] = current_account.award_wallet_user
      end

      def user_loaded?(user:, **)
        # Without the timeout, you sometimes get a weird bug where the BG job
        # loads the user, the polling script redirects to the settings page,
        # and this operation loads the user again... but the user is unloaded,
        # so the operation fails and the user gets redirects to /balances
        # without ever seeing the AW page. I suspect this is something to
        # do with threading, but I don't know enough to investigate further.
        #
        # This crude approach using `sleep` works for now.
        Timeout.timeout(5) do
          sleep 1 until user.reload.loaded?
          true
        end
      rescue Timeout::Error
        false
      end

      def log_not_connected(opts)
        opts['error'] = 'not connected'
      end

      def set_owners_with_accounts(opts, user:, **)
        opts['owners'] = user.award_wallet_owners.includes(:person, award_wallet_accounts: :award_wallet_owner).order(name: :asc)
      end

      def eager_load_people(current_account:, **)
        # Make sure people are loaded here so that the cell doesn't touch the
        # DB.  Note that in previous versions of Rails this would have been
        # written as `current_account.people(true)`, but that's now deprecated.
        current_account.people.reload
      end
    end
  end
end
