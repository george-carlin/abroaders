module Balance::Cell
  # model: a Person
  class Survey < Abroaders::Cell::Base
    include Escaped
    include NameHelper

    property :companion?
    property :first_name
    property :owner?
    property :partner?
    property :type

    option :form

    def title
      if partner?
        "#{first_name}'s Points and Miles"
      else
        'Points and Miles'
      end
    end

    # WARNING: HORRIBLE HACK ALERT
    #
    # override the method in cells-erb-0.0.9/lib/cell/erb/template.rb to ensure
    # that *nothing* cell gets HTML-escaped. If I don't do this,
    # f.fields_for doesn't work (everything within the block gets escaped).
    #
    # This appears to be an issue with cells-erb and erbse, see:
    #
    # https://github.com/trailblazer/cells-erb/issues/2
    #
    # I *could* fix this by upgrading to cells-erb 0.1.0 & erbse 0.1.1 but this
    # breaks a whole bunch of other stuff because there's a bug in these newer
    # versions which means they can't handle inline conditionals; see:
    #
    # https://github.com/apotonick/erbse/issues/4
    # https://github.com/trailblazer/cells-erb/issues/5
    #
    # Overriding 'capture' like this is the least-bad solution I could figure
    # out after an hour or two of frustration :/
    def capture(*args)
      super.html_safe
    end

    private

    def confirm_no
      cell(ConfirmNo, model, options)
    end

    def current_panel
      form.errors.any? ? 'main' : 'initial'
    end

    def fields_for_balance(form_object)
      cell(BalanceFields, form_object)
    end

    def form_tag(&block)
      form_for(
        form,
        method: :post,
        url: survey_person_balances_path(model),
        &block
      )
    end

    def header
      cell(Header, model, options)
    end

    def initial
      cell(Initial, model, options)
    end

    def main
      cell(Main, model, options)
    end

    class ConfirmNo < self
      private

      def body
        you_have = partner? ? "#{first_name} has" : "You have"
        "#{you_have} no existing points or miles balances"
      end
    end

    class Header < self
      def question
        if partner?
          "Does #{first_name} currently have any points or miles?"
        else
          'Do you currently have any points or miles?'
        end
      end
    end

    class Initial < self
    end

    class Main < self
      def header
        do_you = partner? ? "does #{first_name}" : 'do you'
        "What type of points #{do_you} have?"
      end
    end
  end
end
