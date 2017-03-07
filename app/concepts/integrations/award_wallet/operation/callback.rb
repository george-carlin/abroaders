module Integrations
  module AwardWallet
    module Operation
      # Creates an unloaded AwardWalletUser for the current account, and
      # schedules a BG job to load that AWU
      #
      # Flow when users grant us permission to view their AwardWallet data:
      #
      # 1. User clicks a link on our app that takes them to AW.com
      # 2. User clicks 'grant permission' on AW.com
      # 3. AW redirects them back to our 'callback' URL, with 'userId' as a URL
      #    param, and the app runs the operation you're currently looking at.
      #
      # The 'userId' param is the ID of the user's AwardWallet.com account.
      #
      # This operation:
      #
      # - Creates an unloaded AwardWalletUser with the given userId for the
      #   currently logged-in account.
      # - Enqueues a background job that will load the full data from the
      #   AwardWallet API and save it to our database.
      #
      # On the page itself, The user will see a loading spinner, and the JS
      # will poll until it sees that the AWU has been loaded (i.e. that the
      # background job has been run.) Once it sees that the AWU has been
      # loaded, it will redirect the user to the AW config page.
      #
      # Remember that the user can tinker with the URL, refresh the page, or
      # try and visit the callback URL when they shouldn't, so we need to
      # handle some edge cases:
      #
      # - If the current account already has an AwardWalletUser:
      #   - and the AWU is already loaded:
      #     - fail gracefully and redirect to the AW config page
      #   - and the AWU is unloaded:
      #     - they probably just refreshed the page. Show the loading spinner
      #     as if they'd just been redirected to the callback for the first
      #     time, but don't queue a new BG job. (They may have changed the
      #     userId in the URL... ignore whatever's in the URL, just use the
      #     existing AWU.)
      # - If the current account has no AWU:
      #   - and there's no `userId` in the params, or there's a userId that
      #     doesn't look like a real ID (ids are positive integers):
      #     - the user is doing something they shouldn't with the URL; return
      #     a failure and the controller can treat it like a 404.
      #   - and there is a real-looking userId in the URL:
      #     - this is the normal flow!
      #
      # @!method self.call(params, options)
      #   @option params [String] userId provided by the AwardWallet API
      #   @option options [Account] account the currently logged in Account
      class Callback < Trailblazer::Operation
        self['load_user.job'] = User::Operation::Refresh::Job

        step :user_is_not_already_loaded?
        failure :log_user_already_loaded, fail_fast: true
        step :user_id_is_present?
        failure :log_user_id_is_missing
        success :create_user_and_enqueue_job

        private

        def user_is_not_already_loaded?(account:, **)
          account.award_wallet_user.nil? || !account.award_wallet_user.loaded?
        end

        def log_user_already_loaded(opts)
          opts['error'] = 'already loaded'
        end

        # Let them get away with not having a userID in the URL if there's
        # already an unloaded AWU
        def user_id_is_present?(params:, account:)
          !params[:userId].nil? || !account.award_wallet_user.nil?
        end

        def log_user_id_is_missing(opts)
          opts['error'] = 'not found'
        end

        # Create an unloaded AWU and enqueue a job to load it. If the account
        # already has an unloaded AWU, they probably just refreshed the page;
        # no need to create a second AWU or re-enqueue the job.
        def create_user_and_enqueue_job(opts, account:, params:)
          if account.award_wallet_user.nil?
            id = params.fetch(:userId)
            model = account.create_award_wallet_user!(aw_id: id, loaded: false)
            self['load_user.job'].perform_later('id' => model.id)
          else
            model = account.award_wallet_user
          end
          opts['model'] = model
        end
      end
    end
  end
end
