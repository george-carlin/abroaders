class Admin < Admin.superclass
  module Cell
    # model: Admin
    # option: form
    class Edit < Abroaders::Cell::Base
      option :form

      def title
        'Update Admin Account'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        path = admin_registration_path
        form_for form, url: path, html: { method: :put }, &block
      end
    end
  end
end
