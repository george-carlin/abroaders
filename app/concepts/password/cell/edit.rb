module Password
  module Cell
    class Edit < Abroaders::Cell::Base
      include Abroaders::LogoHelper

      def title
        'Update Password'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end
    end
  end
end
