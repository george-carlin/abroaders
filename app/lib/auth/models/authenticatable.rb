require 'active_model/version'
require 'auth/hooks/csrf_cleaner'

module Auth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      BLACKLIST_FOR_SERIALIZATION = [
        :encrypted_password,
        :reset_password_token,
        :reset_password_sent_at,
        :remember_created_at,
        :sign_in_count,
        :current_sign_in_at,
        :last_sign_in_at,
        :current_sign_in_ip,
        :last_sign_in_ip,
        :password_salt,
        :confirmation_token,
        :confirmed_at,
        :confirmation_sent_at,
        :unconfirmed_email,
        :failed_attempts,
        :unlock_token,
        :locked_at,
      ].freeze

      included do
        class_attribute :devise_modules, instance_writer: false
        self.devise_modules ||= []

        before_validation :downcase_keys
        before_validation :strip_whitespace
      end

      def warden_scope
        self.class.warden_scope
      end

      def valid_for_authentication?
        block_given? ? yield : true
      end

      def authenticatable_salt
      end

      # Redefine serializable_hash in models for more secure defaults.
      # By default, it removes from the serializable model all attributes that
      # are *not* accessible. You can remove this default by using :force_except
      # and passing a new list of attributes you want to exempt. All attributes
      # given to :except will simply add names to exempt to Devise internal list.
      def serializable_hash(options = nil)
        options ||= {}
        options[:except] = Array(options[:except])

        if options[:force_except]
          options[:except].concat Array(options[:force_except])
        else
          options[:except].concat BLACKLIST_FOR_SERIALIZATION
        end

        super(options)
      end

      protected

      def send_auth_notification(notification, *args)
        message = Auth::Mailer.send(notification, self, *args)
        message.deliver_now # DEVISETODO
      end

      def downcase_keys
        self.class.case_insensitive_keys.each { |k| self[k] = self[k].try(:downcase) }
      end

      def strip_whitespace
        self.class.strip_whitespace_keys.each { |k| self[k] = self[k].try(:strip) }
      end

      module ClassMethods
        def authentication_keys
          [:email]
        end

        def request_keys
          []
        end

        def strip_whitespace_keys
          [:email]
        end

        def case_insensitive_keys
          [:email]
        end

        def serialize_into_session(record)
          [record.to_key, record.authenticatable_salt]
        end

        def serialize_from_session(key, salt)
          record = find_by_id(key)
          record if record && record.authenticatable_salt == salt
        end

        def find_for_authentication(tainted_conditions)
          find_first_by_auth_conditions(tainted_conditions)
        end

        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          find_by(devise_parameter_filter.filter(tainted_conditions).merge(opts))
        end

        # Find or initialize a record setting an error if it can't be found.
        def find_or_initialize_with_error_by(attribute, value, error = :invalid) #:nodoc:
          find_or_initialize_with_errors([attribute], { attribute => value }, error)
        end

        # Find or initialize a record with group of attributes based on a list of required attributes.
        def find_or_initialize_with_errors(required_attributes, attributes, error = :invalid) #:nodoc:
          attributes = if attributes.respond_to? :permit!
                         attributes.slice(*required_attributes).permit!.to_h.with_indifferent_access
                       else
                         attributes.with_indifferent_access.slice(*required_attributes)
                       end
          attributes.delete_if { |_key, value| value.blank? }

          if attributes.size == required_attributes.size
            record = find_first_by_auth_conditions(attributes)
          end

          unless record
            record = new

            required_attributes.each do |key|
              value = attributes[key]
              record.send("#{key}=", value)
              record.errors.add(key, value.present? ? error : :blank)
            end
          end

          record
        end

        def warden_scope
          name.underscore.to_sym
        end

        protected

        def devise_parameter_filter
          @devise_parameter_filter ||= Auth::ParameterFilter.new(case_insensitive_keys, strip_whitespace_keys)
        end
      end
    end
  end
end
