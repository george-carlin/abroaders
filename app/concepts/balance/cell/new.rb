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

      subclasses_use_parent_view!

      def title
        'Add new balance'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for [form], &block
      end

      def people
        current_account.people.sort_by(&:type).reverse
      end
    end
  end
end
