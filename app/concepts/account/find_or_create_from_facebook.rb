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
    success :find_or_initialize_account
    success :save_account_if_not_persisted

    private

    # In theory they could grant us permission, but only to view their public
    # profile data and not their email, which would make this operation fail.
    # FB has an API to let you request permissions that they've already denied,
    # which I guess we need to use eventually if we want to make this thing
    # more robust, but for now let's just leave it out and let it crash for the
    # small % of users who are awkward enough to refuse to give us their email.

    def find_or_initialize_account(opts, params:, **)
      opts['auth'] = params.fetch(:env).fetch('omniauth.auth')
      opts['model'] = Account.find_or_initialize_by(email: opts['auth']['info']['email'])
    end

    def save_account_if_not_persisted(auth:, model:, **)
      return true unless model.new_record?
      model.build_owner(first_name: auth['info']['first_name'])
      model.password = model.password_confirmation = SecureRandom.hex
      model.save!
    end
  end
end
