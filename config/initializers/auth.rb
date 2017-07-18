# DEVISETODO does this really need to go in an initializer?
ActionView::Base.include Auth::Controllers::UrlHelpers

Auth.add_mapping :accounts
Auth.add_mapping :admins

# DEVISETODO why do I need this? Why not just replace Auth.secret_key with
# Rails.application.secrets.secret_key_base all over the shop?
Auth.secret_key ||= Rails.application.secrets.secret_key_base

Auth.token_generator ||=
  if (secret_key = Auth.secret_key)
    Auth::TokenGenerator.new(
      ActiveSupport::CachingKeyGenerator.new(
        ActiveSupport::KeyGenerator.new(secret_key),
      ),
    )
  end
