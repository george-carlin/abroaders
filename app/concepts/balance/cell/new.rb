class Balance < Balance.superclass
  module Cell
    # @!method self.call(model, options = {})
    #   @option options [Reform::Form] form
    #   @option options [Collection<Currency>] currencies
    #   @option options [Account] current_account
    class New < Abroaders::Cell::Base
      include Escaped

      property :person

      option :currencies
      option :current_account
      option :form

      def title
        text = 'Add new balance'
        text << " for #{escape!(person.first_name)}" if current_account.couples?
        text
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for [person, form], &block
      end
    end
  end
end
