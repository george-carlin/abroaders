require 'auth'
require 'auth/strategies/rememberable'
require 'auth/hooks/rememberable'
require 'auth/hooks/forgetable'

module Auth
  module Models
    # Rememberable manages generating and clearing token for remember the user
    # from a saved cookie. Rememberable also has utility methods for dealing
    # with serializing the user into the cookie and back from the cookie, trying
    # to lookup the record based on the saved information.
    # You probably wouldn't use rememberable methods directly, they are used
    # mostly internally for handling the remember token.
    #
    # == Options
    #
    # Rememberable adds the following options in devise_for:
    #
    #   * +remember_for+: the time you want the user will be remembered without
    #     asking for credentials. After this time the user will be blocked and
    #     will have to enter their credentials again. This configuration is also
    #     used to calculate the expires time for the cookie created to remember
    #     the user. By default remember_for is 2.weeks.
    #
    # == Examples
    #
    #   User.find(1).remember_me!  # regenerating the token
    #   User.find(1).forget_me!    # clearing the token
    #
    #   # generating info to put into cookies
    #   User.serialize_into_cookie(user)
    #
    #   # lookup the user based on the incoming cookie information
    #   User.serialize_from_cookie(cookie_string)
    module Rememberable
      extend ActiveSupport::Concern

      attr_accessor :remember_me

      def remember_me!
        self.remember_created_at ||= Time.now.utc
        save(validate: false) if self.changed?
      end

      # If the record is persisted, remove the remember token (but only if
      # it exists), and save the record without validations.
      def forget_me!
        return unless persisted?
        self.remember_created_at = nil
        save(validate: false)
      end

      def remember_expires_at
        self.class.remember_for.from_now
      end

      def rememberable_value
        if (salt = authenticatable_salt.presence)
          salt
        else
          raise "authenticable_salt returned nil for the #{self.class.name} model. " \
            "In order to use rememberable, you must ensure a password is always set."
        end
      end

      def remember_me?(token, generated_at)
        # TODO: Normalize the JSON type coercion along with the Timeoutable hook
        # in a single place https://github.com/plataformatec/devise/blob/ffe9d6d406e79108cf32a2c6a1d0b3828849c40b/lib/devise/hooks/timeoutable.rb#L14-L18
        if generated_at.is_a?(String)
          generated_at = time_from_json(generated_at)
        end

        # The token is only valid if:
        # 1. we have a date
        # 2. the current time does not pass the expiry period
        # 3. the record has a remember_created_at date
        # 4. the token date is bigger than the remember_created_at
        # 5. the token matches
        generated_at.is_a?(Time) &&
          (self.class.remember_for.ago < generated_at) &&
          (generated_at > (remember_created_at || Time.now).utc) &&
          Auth.secure_compare(rememberable_value, token)
      end

      private

      def time_from_json(value)
        if value =~ /\A\d+\.\d+\Z/
          Time.at(value.to_f)
        else
          begin
            Time.parse(value)
          rescue
            nil
          end
        end
      end

      module ClassMethods
        # Create the cookie key
        def serialize_into_cookie(record)
          [record.to_key, record.rememberable_value, Time.now.utc.to_f.to_s]
        end

        # Recreate the user based on the stored cookie
        def serialize_from_cookie(*args)
          id, token, generated_at = *args

          record = find_by(id: id)
          record if record && record.remember_me?(token, generated_at)
        end

        def remember_for
          2.weeks
        end
      end
    end
  end
end
