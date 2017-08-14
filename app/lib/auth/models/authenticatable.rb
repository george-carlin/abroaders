module Auth
  module Models
    module Authenticatable
      extend ActiveSupport::Concern

      def warden_scope
        self.class.warden_scope
      end

      module ClassMethods
        def warden_scope
          name.underscore.to_sym
        end
      end
    end
  end
end
