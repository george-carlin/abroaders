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

# make sure this is explicitly loaded before dry-validation can kick in, or
# dry-v won't have the custom error messages loaded.
require 'i18n'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Abroaders
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    require "modules/auto_strip_attributes"

    config.cells.with_assets = [
      'account/cell/dashboard',
      'admin_area/accounts/cell/index',
      'admin_area/card_recommendations/cell/new',
      'admin_area/banks/cell/filter_panel',
      'admin_area/people/cell/show',
      'card_account/cell/new/select_product',
      'card_recommendation/cell/actionable',
      'integrations/award_wallet/cell/settings',
      'loyalty_account/cell/table',
      'recommendation_request/cell/call_to_action',
    ]

    config.autoload_paths << Rails.root.join('app', 'models', 'destinations')

    config.generators.jbuilder = false

    config.browserify_rails.commandline_options = [
      "--extension=.js",
      "--extension=.js.jsx",
      "--extension=.jsx",
      "-t [ babelify --presets [ es2015 react ] ]",
    ]

    config.time_zone = "UTC"

    config.exceptions_app = self.routes
  end
end

require 'constants'
# eager-load lib/types; don't leave it to the autoloader, because the file will
# crash if the autoloader loads it twice
require 'types'

# Load ENV variables from a .gitignored YAML file.
unless Rails.env.production? || ENV['CI'] # Heroku and Codeship handle ENV vars differently.
  path = APP_ROOT.join('config', 'application.yml')
  unless File.exist?(path)
    raise 'No config/application.yml detected. Please add a file called '\
          'config/application.yml that contains your ENV setup'
  end

  YAML.load_file(path).each do |key, value|
    if value.is_a?(Hash)
      value.each { |k, v| ENV[k] = v } if key == Rails.env
    else
      ENV[key] = value
    end
  end
end
