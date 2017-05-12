class Admin < Admin.superclass
  module Cell
    class Edit < Abroaders::Cell::Base
      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end
    end
  end
end
