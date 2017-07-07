class Account < Account.superclass
  # Used by the Omniauth callback after a user grants us permission to read
  # their FB data. Takes the 'env' hash from the request and uses the omniauth
  # data to create an account, IFF no account with that email address already
  # exists. If the account already exists then it will just find and return it.
  #
  # I'm not storing the 'code' etc. from the Omniauth hash because as far as I
  # can tell, there's no need to.
  #
  # @!method self.call(params = {}, options = {})
  #   @param params [Hash] env the request.env hash. Must have a key
  #     'omniauth.auth'
  class FindOrCreateFromFacebook < Trailblazer::Operation
    step Wrap(Abroaders::Transaction) {
      success :find_or_create_registration
    }

    private

    # In theory they could grant us permission, but only to view their public
    # profile data and not their email, which would make this operation fail.
    # FB has an API to let you request permissions that they've already denied,
    # which I guess we need to use eventually if we want to make this thing
    # more robust, but for now let's just leave it out and let it crash for the
    # small % of users who are awkward enough to refuse to give us their email.

    def find_or_create_registration(opts, params:, **)
      auth = params.fetch(:env).fetch('omniauth.auth')
      email = auth['info']['email']
      account = Account.find_or_initialize_by(email: email)

      # If an account with this email doesn't already exists in the DB, we need
      # to create it:
      if account.new_record?
        password = SecureRandom.hex
        result = Registration::Create.(
          account: {
            email: email,
            first_name: auth['info']['first_name'],
            password: password,
            password_confirmation: password,
          },
        )
        raise unless result.success? # this should never happen
        account = result['model']
        # We don't actually use this fb_token for anything yet; I just want to
        # store it so we have a record of who signed up from FB, as opposed to
        # signing up through the regular form. Tbh I haven't even looked very
        # closely into how the FB login is supposed to work; if we want to do
        # with FB in future then maybe this token isn't the right thing to
        # store. Proceed with caution:
        account.update_without_password(fb_token: auth['credentials']['token'])
      end
      opts['model'] = account
    end
  end
end
