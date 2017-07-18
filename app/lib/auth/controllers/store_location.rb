require "uri"

module Auth
  module Controllers
    # Provide the ability to store a location.
    # Used to redirect back to a desired path after sign in.
    # Included by default in all controllers.
    module StoreLocation
      # Returns and delete (if it's navigational format) the url stored in the session for
      # the given scope. Useful for giving redirect backs after sign up:

      def stored_location_for(scope)
        session_key = stored_location_key_for(scope)

        if is_navigational_format?
          session.delete(session_key)
        else
          session[session_key]
        end
      end

      # Stores the provided location to redirect the user after signing in.
      # Useful in combination with the `stored_location_for` helper.
      #
      # Example:
      #
      #   store_location_for(:user, dashboard_path)
      #   redirect_to user_omniauth_authorize_path(:facebook)
      #
      def store_location_for(scope, location)
        session_key = stored_location_key_for(scope)
        uri = parse_uri(location)
        if uri
          path = [uri.path.sub(/\A\/+/, '/'), uri.query].compact.join('?')
          path = [path, uri.fragment].compact.join('#')
          session[session_key] = path
        end
      end

      private

      def parse_uri(location)
        location && URI.parse(location)
      rescue URI::InvalidURIError
        nil
      end

      def stored_location_key_for(scope)
        "#{scope}_return_to"
      end
    end
  end
end
