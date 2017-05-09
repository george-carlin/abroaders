class Balance < Balance.superclass
  module Cell
    # @!method self.call(form, options = {})
    #   @param form [Reform::Form]
    #   @option currencies [Collection<Currency>]
    class Edit < Abroaders::Cell::Base
      include Escaped

      option :currencies

      def show
        render 'new'
      end

      def title
        'Edit balance'
      end

      private

      delegate :person, to: :balance

      def balance
        model.model
      end

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, model)
      end

      def form_tag(&block)
        form_for [model], &block
      end
    end
  end
end
