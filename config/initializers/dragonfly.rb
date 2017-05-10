require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "9792d4c625777d0a68af07c74e3dc421eae81a529a8a0a41f66b46f3b44ae7c0"

  url_format "/media/:job/:name"

  datastore :file,
            root_path: Rails.root.join('public/system/dragonfly', Rails.env),
            server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
