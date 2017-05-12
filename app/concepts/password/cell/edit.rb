module Password
  module Cell
    class Edit < Abroaders::Cell::Base
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
