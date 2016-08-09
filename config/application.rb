require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Abroaders
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    require "modules/bootstrap_overrides/overrides"
    require "modules/auto_strip_attributes"

    config.autoload_paths << Rails.root.join("app", "models", "destinations")

    config.generators.jbuilder = false

    config.browserify_rails.commandline_options = [
      "--extension=.js",
      "--extension=.js.jsx",
      "--extension=.jsx",
      "-t [ babelify --presets [ es2015 react ] ]"
    ]
  end
end
