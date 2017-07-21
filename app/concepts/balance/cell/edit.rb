class Balance < Balance.superclass
  module Cell
    # @!method self.call(model, options = {})
    #   @option options [Reform::Form] form
    #   @option options [Collection<Currency>] currencies
    class Edit < Abroaders::Cell::Base
      include Escaped

      property :person

      option :currencies
      option :form

      def show
        render 'new'
      end

      def title
        'Edit balance'
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for [form], &block
      end
    end
  end
end
