module SpendingInfo::Cell
  # model: a SpendingInfo
  class Edit < Abroaders::Cell::Base
    include Escaped

    property :person

    option :form

    delegate :account, to: :person
    delegate :couples?, to: :account

    def title
      'Edit Spending'
    end

    private

    def errors
      cell(Abroaders::Cell::ValidationErrorsAlert, form)
    end

    def form_tag(&block)
      form_for form, url: url, &block
    end

    def has_business_label_text(value)
      case value
      when 'with_ein'
        'Yes, and I have an EIN (Employer ID Number)'
      when 'without_ein'
        'Yes, but I do not have an EIN - I am a freelancer or sole proprietor'
      when 'no_business'
        'I do not own a business'
      end
    end

    def monthly_spending_label_text
      if couples?
        "Please estimate the combined monthly spending for #{owner_first_name}"\
        " and #{companion_first_name} that could be charged to a credit card "\
        'account.'
      else
        'What is your average monthly spending that could be charged to a '\
        'credit card account?'
      end
    end

    def url
      person_spending_info_path(person)
    end

    %w[owner companion].each do |type|
      define_method "#{type}_first_name" do
        escape!(account.send(type).first_name)
      end
    end
  end
end
