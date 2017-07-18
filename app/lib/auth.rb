# rubocop:disable Style/ClassVars
module Auth
  ALL         = [].freeze
  CONTROLLERS = ActiveSupport::OrderedHash.new
  ROUTES      = ActiveSupport::OrderedHash.new
  STRATEGIES  = ActiveSupport::OrderedHash.new
  URL_HELPERS = ActiveSupport::OrderedHash.new

  # Secret key used by the key generator
  mattr_accessor :secret_key
  @@secret_key = nil

  # Custom domain or key for cookies. Not set by default
  mattr_accessor :rememberable_options
  @@rememberable_options = {}

  # Keys used when authenticating a user.
  mattr_accessor :authentication_keys
  @@authentication_keys = [:email]

  # Request keys used when authenticating a user.
  mattr_accessor :request_keys
  @@request_keys = []

  # Keys that should be case-insensitive.
  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [:email]

  # Keys that should have whitespace stripped.
  mattr_accessor :strip_whitespace_keys
  @@strip_whitespace_keys = [:email]

  # If params authenticatable is enabled by default.
  mattr_accessor :params_authenticatable
  @@params_authenticatable = true

  # Email regex used to validate email formats. It asserts that there are no
  # @ symbols or whitespaces in either the localpart or the domain, and that
  # there is a single @ symbol separating the localpart and the domain.
  # DEVISETODO extract to a dry-type or something similar
  mattr_accessor :email_regexp
  @@email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # Range validation for password length
  # DEVISETODO extract to a dry-type or something similar
  mattr_accessor :password_length
  @@password_length = 6..128

  # The time the user will be remembered without asking for credentials again.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  mattr_accessor :extend_remember_period
  @@extend_remember_period = false

  # If true, all the remember me tokens are going to be invalidated when the user signs out.
  mattr_accessor :expire_all_remember_me_on_sign_out
  @@expire_all_remember_me_on_sign_out = true

  # Used to hash the password. Please generate one with rake secret.
  mattr_accessor :pepper
  @@pepper = true

  # Used to enable sending notification to user when their password is changed
  mattr_accessor :send_password_change_notification
  @@send_password_change_notification = false

  # Defines which key will be used when recovering the password for an account
  mattr_accessor :reset_password_keys
  @@reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key
  mattr_accessor :reset_password_within
  @@reset_password_within = 6.hours

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  # Which formats should be treated as navigational.
  mattr_accessor :navigational_formats
  @@navigational_formats = ["*/*", :html]

  # The router Devise should use to generate routes. Defaults
  # to :main_app. Should be overridden by engines in order
  # to provide custom routes.
  mattr_accessor :router_name
  @@router_name = nil

  # Set if we should clean up the CSRF Token on authentication
  mattr_accessor :clean_up_csrf_token_on_authentication
  @@clean_up_csrf_token_on_authentication = true

  # PRIVATE CONFIGURATION

  # Store scopes mappings.
  mattr_reader :mappings
  @@mappings = ActiveSupport::OrderedHash.new

  # OmniAuth configurations.
  mattr_reader :omniauth_configs
  @@omniauth_configs = ActiveSupport::OrderedHash.new

  # Define a set of modules that are called when a mapping is added.
  mattr_reader :helpers
  @@helpers = Set.new
  @@helpers << Auth::Controllers::Helpers

  # Private methods to interface with Warden.
  mattr_accessor :warden_config
  @@warden_config = nil
  @@warden_config_blocks = []

  # When true, enter in paranoid mode to avoid user enumeration.
  mattr_accessor :paranoid
  @@paranoid = false

  # Stores the token generator
  mattr_accessor :token_generator
  @@token_generator = nil

  # Default way to set up Auth. Run rails generate devise_install to create
  # a fresh initializer with all configuration values.
  def self.setup
    yield self
  end

  class Getter
    def initialize(name)
      @name = name
    end

    def get
      ActiveSupport::Dependencies.constantize(@name)
    end
  end

  def self.ref(arg)
    ActiveSupport::Dependencies.reference(arg)
    Getter.new(arg)
  end

  def self.omniauth_providers
    omniauth_configs.keys
  end

  # Small method that adds a mapping to Auth.
  def self.add_mapping(resource, options = {})
    mapping = Auth::Mapping.new(resource, options)
    @@mappings[mapping.name] = mapping
    @@default_scope ||= mapping.name
    @@helpers.each { |h| h.define_helpers(mapping) }
    mapping
  end

  # Register available devise modules. For the standard modules that Devise provides, this method is
  # called from lib/devise/modules.rb. Third-party modules need to be added explicitly using this method.
  #
  # Note that adding a module using this method does not cause it to be used in the authentication
  # process. That requires that the module be listed in the arguments passed to the 'devise' method
  # in the model class definition.
  #
  # == Options:
  #
  #   +model+      - String representing the load path to a custom *model* for this module (to autoload.)
  #   +controller+ - Symbol representing the name of an existing or custom *controller* for this module.
  #   +route+      - Symbol representing the named *route* helper for this module.
  #   +strategy+   - Symbol representing if this module got a custom *strategy*.
  #   +insert_at+  - Integer representing the order in which this module's model will be included
  #
  # All values, except :model, accept also a boolean and will have the same name as the given module
  # name.
  #
  # == Examples:
  #
  #   Auth.add_module(:party_module)
  #   Auth.add_module(:party_module, strategy: true, controller: :sessions)
  #   Auth.add_module(:party_module, model: 'party_module/model')
  #   Auth.add_module(:party_module, insert_at: 0)
  #
  def self.add_module(module_name, options = {})
    options.assert_valid_keys(:strategy, :model, :controller, :route, :insert_at)

    ALL.insert (options[:insert_at] || -1), module_name

    if (strategy = options[:strategy])
      strategy = (strategy == true ? module_name : strategy)
      STRATEGIES[module_name] = strategy
    end

    if (controller = options[:controller])
      controller = (controller == true ? module_name : controller)
      CONTROLLERS[module_name] = controller
    end

    if (route = options[:route])
      case route
      when TrueClass
        key = module_name
        value = []
      when Symbol
        key = route
        value = []
      when Hash
        key = route.keys.first
        value = route.values.flatten
      else
        raise ArgumentError, ":route should be true, a Symbol or a Hash"
      end

      URL_HELPERS[key] ||= []
      URL_HELPERS[key].concat(value)
      URL_HELPERS[key].uniq!

      ROUTES[module_name] = key
    end

    if options[:model]
      path = (options[:model] == true ? "devise/models/#{module_name}" : options[:model])
      camelized = ActiveSupport::Inflector.camelize(module_name.to_s)
      Auth::Models.send(:autoload, camelized.to_sym, path)
    end

    Auth::Mapping.add_module module_name
  end

  # Sets warden configuration using a block that will be invoked on warden
  # initialization.
  #
  #  Auth.setup do |config|
  #    config.allow_unconfirmed_access_for = 2.days
  #
  #    config.warden do |manager|
  #      # Configure warden to use other strategies, like oauth.
  #      manager.oauth(:twitter)
  #    end
  #  end
  def self.warden(&block)
    @@warden_config_blocks << block
  end

  # Specify an OmniAuth provider.
  #
  #   config.omniauth :github, APP_ID, APP_SECRET
  #
  def self.omniauth(provider, *args)
    @@helpers << Auth::OmniAuth::UrlHelpers
    config = Auth::OmniAuth::Config.new(provider, args)
    @@omniauth_configs[config.strategy_name.to_sym] = config
  end

  # Include helpers in the given scope to AC and AV.
  # DEVISETODO aren't any including these anyway?
  def self.include_helpers(scope)
    ActiveSupport.on_load(:action_controller) do
      include scope::Helpers if defined?(scope::Helpers)
      include scope::UrlHelpers
    end

    ActiveSupport.on_load(:action_view) do
      include scope::UrlHelpers
    end
  end

  # Regenerates url helpers considering Auth.mapping
  def self.regenerate_helpers!
    Auth::Controllers::UrlHelpers.remove_helpers!
    Auth::Controllers::UrlHelpers.generate_helpers!
  end

  # A method used internally to complete the setup of warden manager after routes are loaded.
  # See lib/devise/rails/routes.rb - ActionDispatch::Routing::RouteSet#finalize_with_devise!
  def self.configure_warden! #:nodoc:
    @@warden_configured ||= begin
      warden_config.failure_app   = Auth::Delegator.new
      warden_config.default_scope = Auth.default_scope
      warden_config.intercept_401 = false

      Auth.mappings.each_value do |mapping|
        warden_config.scope_defaults mapping.name, strategies: mapping.strategies

        warden_config.serialize_into_session(mapping.name) do |record|
          mapping.to.serialize_into_session(record)
        end

        warden_config.serialize_from_session(mapping.name) do |args|
          mapping.to.serialize_from_session(*args)
        end
      end

      @@warden_config_blocks.map { |block| block.call Auth.warden_config }
      true
    end
  end

  # Generate a friendly string randomly to be used as token.
  # By default, length is 20 characters.
  def self.friendly_token(length = 20)
    # To calculate real characters, we must perform this operation.
    # See SecureRandom.urlsafe_base64
    rlength = (length * 3) / 4
    SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
  end

  # constant-time comparison algorithm to prevent timing attacks
  def self.secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end

require 'warden'
require 'auth/mapping'
