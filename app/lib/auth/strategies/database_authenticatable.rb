module Auth
  module Strategies
    class DatabaseAuthenticatable < Authenticatable
      attr_accessor :authentication_hash, :authentication_type, :password

      def authenticate!
        resource = password.present? && model.find_for_database_authentication(authentication_hash)
        hashed = false

        valid = validate(resource) do
          hashed = true
          resource.valid_password?(password)
        end

        if valid
          remember_me(resource)
          success!(resource)
        end

        raise(:not_found_in_database) unless resource
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Auth::Strategies::DatabaseAuthenticatable)
