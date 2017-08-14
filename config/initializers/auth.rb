Auth.add_mapping :accounts
Auth.add_mapping :admins

Auth.token_generator ||=
  if (secret_key = Auth.secret_key)
    Auth::TokenGenerator.new(
      ActiveSupport::CachingKeyGenerator.new(
        ActiveSupport::KeyGenerator.new(secret_key),
      ),
    )
  end
