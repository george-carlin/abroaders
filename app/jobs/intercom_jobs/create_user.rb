module IntercomJobs
  class CreateUser < ApplicationJob
    queue_as :intercom

    # opts (all string keys):
    #   email: email of the new account
    #   name: name of the new account's owner
    #   signed_up_at: an INTEGER that represents a UNIX time
    def perform(opts = {})
      INTERCOM.users.create(
        email:        opts.fetch('email'),
        name:         opts.fetch('name'),
        signed_up_at: opts.fetch('signed_up_at'),
      )
    end
  end
end
