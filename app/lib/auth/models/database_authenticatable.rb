require 'auth/strategies/database_authenticatable'

module Auth
  module Models
    # Authenticatable Module, responsible for hashing the password and
    # validating the authenticity of a user while signing in.
    #
    # == Examples
    #
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module DatabaseAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :password, :current_password
        attr_accessor :password_confirmation
      end

      # Generates a hashed password based on the given value.
      # For legacy reasons, we use `encrypted_password` to store
      # the hashed password.
      def password=(new_password)
        @password = new_password
        self.encrypted_password = Auth::Encryptor.digest(@password) if @password.present?
      end

      # Verifies whether a password (ie from sign in) is the user password.
      def valid_password?(password)
        Auth::Encryptor.compare(encrypted_password, password)
      end

      # Set password and password confirmation to nil
      def clean_up_passwords
        self.password = self.password_confirmation = nil
      end

      # Update record attributes when :current_password matches, otherwise
      # returns error on :current_password.
      #
      # This method also rejects the password field if it is blank (allowing
      # users to change relevant information like the e-mail without changing
      # their password). In case the password field is rejected, the confirmation
      # is also rejected as long as it is also blank.
      def update_with_password(params, *options)
        current_password = params.delete(:current_password)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end

        result = if valid_password?(current_password)
                   update_attributes(params, *options)
                 else
                   self.assign_attributes(params, *options)
                   self.valid?
                   self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                   false
                 end

        clean_up_passwords
        result
      end

      # Updates record attributes without asking for the current password.
      # Never allows a change to the current password. If you are using this
      # method, you should probably override this method to protect other
      # attributes you would not like to be updated without a password.
      #
      # Example:
      #
      #   def update_without_password(params, *options)
      #     params.delete(:email)
      #     super(params)
      #   end
      #
      def update_without_password(params, *options)
        params.delete(:password)
        params.delete(:password_confirmation)

        result = update_attributes(params, *options)
        clean_up_passwords
        result
      end

      # Destroy record when :current_password matches, otherwise returns
      # error on :current_password. It also automatically rejects
      # :current_password if it is blank.
      def destroy_with_password(current_password)
        result = if valid_password?(current_password)
                   destroy
                 else
                   self.valid?
                   self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                   false
                 end

        result
      end

      # A reliable way to expose the salt regardless of the implementation.
      def authenticatable_salt
        encrypted_password[0, 29] if encrypted_password
      end

      protected

      module ClassMethods
        # We assume this method already gets the sanitized values from the
        # DatabaseAuthenticatable strategy. If you are using this method on
        # your own, be sure to sanitize the conditions hash to only include
        # the proper fields.
        def find_for_database_authentication(conditions)
          find_for_authentication(conditions)
        end
      end
    end
  end
end
