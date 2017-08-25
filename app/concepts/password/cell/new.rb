module Password
  module Cell
    class New < Abroaders::Cell::Base
      include Abroaders::LogoHelper

      def title
        'Reset Password'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end
    end
  end
end
