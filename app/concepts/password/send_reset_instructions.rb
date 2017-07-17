module Password
  # Attempt to find a user by its email. If a record is found, send new
  # password instructions to it. If user is not found, returns a new user
  # with an email not found error.
  #
  # Attributes must contain the user's email
  #
  # Resets reset password token and send reset password instructions by email.
  # Returns the token sent in the e-mail.
  class SendResetInstructions < Trailblazer::Operation
    self['token_generator'] = Auth.token_generator

    success :setup_account
    step :account_persisted?
    step :set_reset_token!
    step :send_reset_notification!
    failure :set_account_error_messages!

    private

    def setup_account(opts, params:, **)
      email = params.fetch(:account).fetch(:email).strip
      opts['model'] = Account.find_or_initialize_by(email: email)
    end

    def account_persisted?(model:, **)
      model.persisted?
    end

    def set_reset_token!(opts, model:, **)
      token_generator = opts['token_generator']
      token, encrypted_token = token_generator.generate(Account, :reset_password_token)

      model.reset_password_token   = encrypted_token
      model.reset_password_sent_at = Time.now.utc
      model.save(validate: false)
      opts['token'] = token
    end

    def send_reset_notification!(model:, token:, **)
      message = Auth::Mailer.reset_password_instructions(model, token, {})
      message.deliver_now
    end

    def set_account_error_messages!(model:, **)
      model.errors.add(:email, :not_found)
    end
  end
end
