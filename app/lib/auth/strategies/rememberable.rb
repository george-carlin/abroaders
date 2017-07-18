module Auth
  module Strategies
    # Remember the user through the remember token. This strategy is responsible
    # to verify whether there is a cookie with the remember token, and to
    # recreate the user from this cookie if it exists. Must be called *before*
    # authenticatable.
    class Rememberable < Authenticatable
      # A valid strategy for rememberable needs a remember token in the cookies.
      def valid?
        @remember_cookie = nil
        remember_cookie.present?
      end

      # To authenticate a user we deserialize the cookie and attempt finding
      # the record in the database. If the attempt fails, we pass to another
      # strategy handle the authentication.
      def authenticate!
        resource = model.serialize_from_cookie(*remember_cookie)

        unless resource
          cookies.delete(remember_key)
          return pass
        end

        success!(resource) if validate(resource)
      end

      # No need to clean up the CSRF when using rememberable.
      # In fact, cleaning it up here would be a bug because
      # rememberable is triggered on GET requests which means
      # we would render a page on first access with all csrf
      # tokens expired.
      def clean_up_csrf?
        false
      end

      private

      def remember_me?
        true
      end

      def remember_key
        "remember_#{scope}_token"
      end

      def remember_cookie
        @remember_cookie ||= cookies.signed[remember_key]
      end
    end
  end
end

Warden::Strategies.add(:rememberable, Auth::Strategies::Rememberable)
