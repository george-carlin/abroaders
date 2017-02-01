module Abroaders
  module Cell
    # model: a Reform contract. If the contract has no errors (which could mean
    # that it hasn't been validated yet), the cell will return an empty string.
    # Else, it will return a Bootstrap 'danger' alert containing info about the
    # errors.
    #
    # NOTE: the contract must use dry-validation for validation, not
    # ActiveModel. For ActiveModel errors use ValidationErrorsAlert::ActiveModel
    class ValidationErrorsAlert < Trailblazer::Cell
      alias contract model

      def show
        return '' if error_messages.empty?
        cell(ErrorAlert, nil, content: render)
      end

      private

      # will return a Hash in the format { key: ['err1', 'err2'] }.
      def error_messages
        contract.errors.messages
      end

      # reform will drop support for ActiveModel eventually, so we should start
      # thinking about converting all AM forms to use dry-v.
      class ActiveModel < Trailblazer::Cell
        alias contract model

        def show
          return '' if errors.empty?
          cell(ErrorAlert, nil, content: render)
        end

        private

        def intro
          result = 'There '
          result << if errors.count > 1
                      "were #{errors.count} errors"
                    else
                      'was an error'
                    end
          result << " and the #{model_name} could not be saved:"
          result
        end

        def errors
          contract.errors
        end

        def model_name
          contract.model.model_name.human.downcase
        end
      end
    end
  end
end
