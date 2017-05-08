class Balance < Balance.superclass
  module Cell
    # @!method self.call(balance, options = {})
    #   @param form [Reform::Form]
    #   @option current_account [Account]
    class New < Abroaders::Cell::Base
      include Escaped

      option :currencies
      option :current_account

      def title
        text = "Add new balance"
        text << " for #{escape!(person.first_name)}" if current_account.couples?
        text
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
        form_for [person, model], &block
      end
    end
  end
end
