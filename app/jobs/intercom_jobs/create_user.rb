module IntercomJobs
  class CreateUser < ApplicationJob
    queue_as :intercom

    def perform(opts = {})
      opts.symbolize_keys!
      account = Account.find(opts.fetch(:account_id))
      INTERCOM.users.create(
        email:        account.email,
        name:         account.owner_first_name,
        signed_up_at: account.created_at.to_i,
      )
    end
  end
end
