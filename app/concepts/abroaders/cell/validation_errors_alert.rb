module Abroaders
  module Cell
    # model: a Reform contract. If the contract has no errors (which could mean
    # that it hasn't been validated yet), the cell will return an empty string.
    # Else, it will return a Bootstrap 'danger' alert containing info about the
    # errors.
    class ValidationErrorsAlert < Trailblazer::Cell
      alias form model

      def show
        return '' if error_messages.empty?
        cell(ErrorAlert, nil, content: render)
      end

      private

      def error_messages
        form.errors.messages
      end
    end
  end
end
