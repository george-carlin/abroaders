module Registration::Cell
  class Edit < Abroaders::Cell::Base
    include Abroaders::LogoHelper

    option :form

    def title
      'Edit Account Settings'
    end

    private

    def errors
      cell(Abroaders::Cell::ValidationErrorsAlert, form)
    end

    def form_tag(&block)
      form_for form, as: :account, url: account_path, html: { role: 'form' }, &block
    end
  end
end
