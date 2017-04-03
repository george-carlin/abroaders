module Integrations::AwardWallet
  class Settings < Trailblazer::Operation
    step :set_user
    step :user_loaded?
    failure :log_not_connected
    step :set_owners_with_accounts
    step :eager_load_people

    private

    def set_user(opts, account:, **)
      opts['user'] = account.award_wallet_user
    end

    def user_loaded?(opts)
      opts['user'].loaded?
    end

    def log_not_connected(opts)
      opts['error'] = 'not connected'
    end

    def set_owners_with_accounts(opts, user:, **)
      opts['owners'] = user.award_wallet_owners.includes(:person, award_wallet_accounts: :award_wallet_owner).order(name: :asc)
    end

    def eager_load_people(account:, **)
      # Make sure people are loaded here so that the cell doesn't touch the
      # DB.  Note that in previous versions of Rails this would have been
      # written as `account.people(true)`, but that's now deprecated.
      account.people.reload
    end
  end
end
