# rubocop:disable Style/ClassVars
module Auth
  ALL         = [].freeze
  ROUTES      = ActiveSupport::OrderedHash.new
  STRATEGIES  = ActiveSupport::OrderedHash.new

  def self.secret_key
    Rails.application.secrets.secret_key_base
  end

  # How many times to hash a password
  def self.stretches
    Rails.env.test? ? 1 : 10
  end

  # Keys that should be case-insensitive.
  mattr_accessor :case_insensitive_keys
  @@case_insensitive_keys = [:email]

  # Keys that should have whitespace stripped.
  mattr_accessor :strip_whitespace_keys
  @@strip_whitespace_keys = [:email]

  # The default scope which is used by warden.
  mattr_accessor :default_scope
  @@default_scope = nil

  def self.navigational_format?(format)
    ["*/*", :html].include?(format)
  end

  # The router Devise should use to generate routes. Defaults
  # to :main_app. Should be overridden by engines in order
  # to provide custom routes.
  mattr_accessor :router_name
  @@router_name = nil

  # PRIVATE CONFIGURATION

  # Store scopes mappings.
  mattr_reader :mappings
  @@mappings = ActiveSupport::OrderedHash.new

  # Define a set of modules that are called when a mapping is added.
  mattr_reader :helpers
  @@helpers = Set.new
  @@helpers << Auth::Controllers::Helpers

  # Stores the token generator
  mattr_accessor :token_generator
  @@token_generator = nil

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

  # Small method that adds a mapping to Auth.
  def self.add_mapping(resource, options = {})
    mapping = Auth::Mapping.new(resource, options)
    @@mappings[mapping.name] = mapping
    @@default_scope ||= mapping.name
    @@helpers.each { |h| h.define_helpers(mapping) }
    mapping
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
