module Auth
  module Strategies
    # Base strategy. Responsible for verifying correct scope and mapping.
    class Base < ::Warden::Strategies::Base
      # Whenever CSRF cannot be verified, we turn off any kind of storage
      def store?
        !env["devise.skip_storage"]
      end

      def model
        scope.to_s.classify.constantize
      end
    end
  end
end
