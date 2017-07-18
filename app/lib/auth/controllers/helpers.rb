module Auth
  module Controllers
    # Those helpers are convenience methods added to ApplicationController.
    module Helpers
      extend ActiveSupport::Concern
      include Auth::Controllers::SignInOut
      include Auth::Controllers::StoreLocation

      included do
        helper_method :warden, :signed_in? if respond_to?(:helper_method)
      end

      # Define authentication filters and accessor helpers based on mappings.
      # These filters should be used inside the controllers as before_actions,
      # so you can control the scope of the user who should be signed in to
      # access that specific controller/action.
      # Example:
      #
      #   Roles:
      #     User
      #     Admin
      #
      #   Generated methods:
      #     authenticate_user!  # Signs user in or redirect
      #     authenticate_admin! # Signs admin in or redirect
      #     user_signed_in?     # Checks whether there is a user signed in or not
      #     admin_signed_in?    # Checks whether there is an admin signed in or not
      #     current_user        # Current signed in user
      #     current_admin       # Current signed in admin
      #     user_session        # Session data available only to the user scope
      #     admin_session       # Session data available only to the admin scope
      #
      #   Use:
      #     before_action :authenticate_user!  # Tell devise to use :user map
      #     before_action :authenticate_admin! # Tell devise to use :admin map
      #
      # This method is called from Auth.add_mapping, i.e. in real
      # Devise it's called when you add devise_for in your routes.
      def self.define_helpers(mapping) #:nodoc:
        mapping = mapping.name

        class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def authenticate_#{mapping}!(opts={})
            opts[:scope] = :#{mapping}
            warden.authenticate!(opts) if !auth_controller? || opts.delete(:force)
          end

          def #{mapping}_signed_in?
            !!current_#{mapping}
          end

          def current_#{mapping}
            @current_#{mapping} ||= warden.authenticate(scope: :#{mapping})
          end

          def #{mapping}_session
            current_#{mapping} && warden.session(:#{mapping})
          end
        METHODS

        ActiveSupport.on_load(:action_controller) do
          if respond_to?(:helper_method)
            helper_method "current_#{mapping}", "#{mapping}_signed_in?", "#{mapping}_session"
          end
        end
      end

      # The main accessor for the warden proxy instance
      def warden
        request.env['warden']
      end

      # Set up a param sanitizer to filter parameters using strong_parameters. See
      # lib/devise/parameter_sanitizer.rb for more info. Override this
      # method in your application controller to use your own parameter sanitizer.
      def devise_parameter_sanitizer
        @devise_parameter_sanitizer ||= Auth::ParameterSanitizer.new(resource_class, resource_name, params)
      end

      # Tell warden that params authentication is allowed for that specific page.
      def allow_params_authentication!
        request.env["devise.allow_params_authentication"] = true
      end

      def after_sign_in_path_for(resource)
        stored_location_for(resource.warden_scope) || root_path
      end

      # Overwrite Rails' handle unverified request to sign out all scopes,
      # clear run strategies and remove cached variables.
      def handle_unverified_request
        super # call the default behaviour which resets/nullifies/raises
        request.env["devise.skip_storage"] = true
        sign_out_all_scopes(false)
      end

      def request_format
        @request_format ||= request.format.try(:ref)
      end

      def is_navigational_format?
        Auth.navigational_formats.include?(request_format)
      end

      # Check if flash messages should be emitted. Default is to do it on
      # navigational formats
      def is_flashing_format?
        is_navigational_format?
      end

      private

      def expire_data_after_sign_out!
        Auth.mappings.each { |_, m| instance_variable_set("@current_#{m.name}", nil) }
        super
      end
    end
  end
end
