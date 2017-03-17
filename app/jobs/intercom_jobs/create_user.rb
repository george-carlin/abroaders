module IntercomJobs
  class CreateUser < IntercomJobs::Base
    queue_as :intercom

    # @param opts
    # @option opts [String] email email of the new account
    # @option opts [String] name name of the new account's owner
    # @option opts [Integer] signed_up_at an int that represents a UNIX time
    def perform(opts = {})
      INTERCOM.users.create(
        email:        opts.fetch('email'),
        name:         opts.fetch('name'),
        signed_up_at: opts.fetch('signed_up_at'),
      )
    end
  end
end
