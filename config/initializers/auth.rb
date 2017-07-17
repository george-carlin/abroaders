# DEVISETODO does this really need to go in an initializer?
ActionView::Base.include Auth::Controllers::UrlHelpers

Auth.add_mapping :accounts
Auth.add_mapping :admins

# DEVISETODO why do I need this? Why not just replace Auth.secret_key with
# Rails.application.secrets.secret_key_base all over the shop?
Auth.secret_key ||= Rails.application.secrets.secret_key_base

Auth.token_generator ||=
  if secret_key = Auth.secret_key
    Auth::TokenGenerator.new(
      ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key)),
    )
  end

# All this was from devise/lib/devise/rails.rb
# module Devise
#   class Engine < ::Rails::Engine
#     config.devise = Devise
#
#     # Initialize Warden and copy its configurations.
#     config.app_middleware.use Warden::Manager do |config|
#       Auth.warden_config = config
#     end
#
#     # Force routes to be loaded if we are doing any eager load.
#     config.before_eager_load { |app| app.reload_routes! }
#
#     initializer "devise.url_helpers" do
#       Auth.include_helpers(Auth::Controllers)
#     end
#
#     initializer "devise.omniauth", after: :load_config_initializers, before: :build_middleware_stack do |app|
#       Auth.omniauth_configs.each do |provider, config|
#         app.middleware.use config.strategy_class, *config.args do |strategy|
#           config.strategy = strategy
#         end
#       end
#
#       if Auth.omniauth_configs.any?
#         Auth.include_helpers(Auth::OmniAuth)
#       end
#     end
#
#     initializer "devise.secret_key" do |app|
#       if app.respond_to?(:secrets)
#         Auth.secret_key ||= app.secrets.secret_key_base
#       elsif app.config.respond_to?(:secret_key_base)
#         Auth.secret_key ||= app.config.secret_key_base
#       end
#
#       Auth.token_generator ||=
#         if secret_key = Auth.secret_key
#           Auth::TokenGenerator.new(
#             ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(secret_key))
#           )
#         end
#     end
#   end
# end
