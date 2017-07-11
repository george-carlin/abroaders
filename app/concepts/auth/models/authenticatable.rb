require 'active_model/version'

module Auth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      # DEVISETODO My addition on top of devise. Devise finds the resource
      # name with code like: 
      #
      #    Devise::Mapping.find_scope!(Account)
      #    # => :account 
      #    # or:
      #    Devise::Mapping.find_scope!(Account.last)
      #    # => :account 
      #   
      # I don't see why it needs to be so complicated
      def warden_scope
        self.class.warden_scope
      end

      protected

      module ClassMethods
        def warden_scope
          name.underscore.to_sym
        end
      end
    end
  end
end
