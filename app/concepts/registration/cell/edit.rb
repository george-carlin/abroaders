module Registration::Cell
  class Edit < Abroaders::Cell::Base
    include Abroaders::LogoHelper

    option :form

    def title
      'Email & Password Settings'
    end

    private

    def errors
      cell(Abroaders::Cell::ValidationErrorsAlert, form)
    end

    def form_tag(&block)
      form_for form, as: :account, url: account_path, html: { role: 'form' }, &block
    end

    def submit_btn(f)
      f.submit 'Save Account Settings', class: 'btn btn-primary btn-lg'
    end
  end
end
