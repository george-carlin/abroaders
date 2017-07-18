require "action_controller/metal"

# DEVISETODO do we really need something of this complexity? Audit the 'StoreLocation'
# helper too.
module Auth
  # Failure application that will be called every time :warden is thrown from
  # any strategy or hook. Responsible for redirect the user to the sign in
  # page based on current scope and mapping. If no scope is given, redirect
  # to the default_url.
  class FailureApp < ActionController::Metal
    include ActionController::UrlFor
    include ActionController::Redirecting

    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers

    include Auth::Controllers::StoreLocation

    delegate :flash, to: :request

    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def self.default_url_options(*)
      ApplicationController.default_url_options
    end

    def respond
      warden_options[:recall] ? recall : redirect
    end

    def recall
      key = 'PATH_INFO'
      if request.respond_to?(:set_header)
        request.set_header(key, attempted_path)
      else
        env[key] = attempted_path
      end

      flash.now[:alert] = i18n_message(:invalid) if is_flashing_format?

      # e.g. they may have passed 'sessions_controller#new' as the recall action
      controller, action = warden_options[:recall].split("#")
      controller_class = "#{controller.camelize}Controller".constantize
      self.response = controller_class.action(action).call(request.env)
    end

    def redirect
      store_location!
      flash[:alert] = i18n_message if is_flashing_format?
      redirect_to scope_url
    end

    protected

    def i18n_options(options)
      options
    end

    def i18n_message(default = nil)
      message = warden_message || default || :unauthenticated

      if message.is_a?(Symbol)
        options = {}
        options[:resource_name] = scope
        options[:scope] = "devise.failure"
        options[:default] = [message]
        auth_keys = scope_class.authentication_keys
        keys = (auth_keys.respond_to?(:keys) ? auth_keys.keys : auth_keys).map { |key| scope_class.human_attribute_name(key) }
        options[:authentication_keys] = keys.join(I18n.translate(:"support.array.words_connector"))
        options = i18n_options(options)

        I18n.t(:"#{scope}.#{message}", options)
      else
        message.to_s
      end
    end

    def scope_url
      opts = {}
      opts[:format] = request_format unless skip_format?
      main_app.send(:"new_#{scope}_session_url", opts)
    end

    def skip_format?
      %w(html */*).include? request_format.to_s
    end

    def warden
      request.respond_to?(:get_header) ? request.get_header("warden") : env["warden"]
    end

    def warden_options
      request.respond_to?(:get_header) ? request.get_header("warden.options") : env["warden.options"]
    end

    def warden_message
      @message ||= warden.message || warden_options[:message]
    end

    def scope
      @scope ||= warden_options[:scope] || Auth.default_scope
    end

    def scope_class
      @scope_class ||= Auth.mappings[scope].to
    end

    def attempted_path
      warden_options[:attempted_path]
    end

    # Stores requested uri to redirect the user after signing in. We cannot use
    # scoped session provided by warden here, since the user is not authenticated
    # yet, but we still need to store the uri based on scope, so different scopes
    # would never use the same uri to redirect.
    def store_location!
      store_location_for(scope, attempted_path) if request.get?
    end

    # Check if flash messages should be emitted. Default is to do it on
    # navigational formats
    def is_flashing_format?
      Auth.navigational_format?(request_format)
    end

    def request_format
      @request_format ||= request.format.try(:ref)
    end
  end
end
