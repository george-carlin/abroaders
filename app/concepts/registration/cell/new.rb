module Registration
  module Cell
    # @!method self.call(form, options = {})
    #   @param form [Reform::Form]
    class New < Abroaders::Cell::Base
      def title
        'Sign Up'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end

      def form_tag(&block)
        form_for model, url: account_registration_path, html: { role: 'form' }, &block
      end

      def minimum_password_length
        Registration::SignUpForm::PASSWORD_LENGTH.min
      end
    end
  end
end
