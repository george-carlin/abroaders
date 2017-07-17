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

    config.assets.quiet = true

    config.generators.jbuilder = false

    config.browserify_rails.commandline_options = [
      "--extension=.js",
      "--extension=.js.jsx",
      "--extension=.jsx",
      "-t [ babelify --presets [ es2015 react ] ]",
    ]

    config.time_zone = "UTC"

    config.app_middleware.use Warden::Manager do |config|
      # DEVISETODO when devise is installed, Auth.warden_config just
      # gets set to the `config` var that's passed to this block.
      #
      # Seems like with devise, the warden_config is left unaltered from
      # the default `config` I'm getting here, except the key :failure_app
      # is added, pointing to an instance of Auth::Delegator
      #
      # With devise installed, Warden::Manager is present in the middleware
      # (in between Rack::ETag and OmniAuth::Builder, so it seems I do need to
      # add it here)
      config.failure_app = Auth::FailureApp # DEVISETODO
      config.default_strategies :database_authenticatable, :rememberable

      [Account, Admin].each do |model| # DEVISE TODO
        config.serialize_into_session(model.warden_scope) do |record|
          model.serialize_into_session(record)
        end

        config.serialize_from_session(model.warden_scope) do |args|
          model.serialize_from_session(*args)
        end
      end
    end

    config.exceptions_app = self.routes

    if ENV['ASSET_HOST']
      # See https://stackoverflow.com/a/36585871/1603071
      config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins %w[
            https://*.abroaders.com
            http://*.abroaders.com
            https://abroaders-staging.herokuapp.com
            https://abroaders.herokuapp.com
          ]
          resource '/assets/*'
        end
      end
    end
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
