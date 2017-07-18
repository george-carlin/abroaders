module Auth
  module Controllers
    # A module that may be optionally included in a controller in order
    # to provide remember me behavior. Useful when signing in is done
    # through a callback, like in OmniAuth.
    module Rememberable
      # Return default cookie values retrieved from session options.
      def self.cookie_values
        Rails.configuration.session_options.slice(:path, :domain, :secure)
      end

      def remember_me_is_active?(resource)
        return false unless resource.respond_to?(:remember_me)
        scope = resource.warden_scope
        _, token, generated_at = cookies.signed[remember_key(scope)]
        resource.remember_me?(token, generated_at)
      end

      # Remembers the given resource by setting up a cookie
      def remember_me(resource)
        return if env["devise.skip_storage"]
        scope = resource.warden_scope
        resource.remember_me!
        cookies.signed[remember_key(scope)] = remember_cookie_values(resource)
      end

      # Forgets the given resource by deleting a cookie
      def forget_me(resource)
        scope = resource.warden_scope
        resource.forget_me!
        cookies.delete(remember_key(scope), forget_cookie_values)
      end

      protected

      def forget_cookie_values
        Auth::Controllers::Rememberable.cookie_values.merge!({})
      end

      def remember_cookie_values(resource)
        options = { httponly: true }
        options.merge!(forget_cookie_values)
        options.merge!(
          value: resource.class.serialize_into_cookie(resource),
          expires: resource.remember_expires_at,
        )
      end

      def remember_key(scope)
        "remember_#{scope}_token"
      end
    end
  end
end
