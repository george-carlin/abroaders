module Abroaders
  module Cell
    # @!method self.call(contract)
    #   @param contract [Reform::Form] If the contract has no errors (which could mean
    #     that it hasn't been validated yet), the cell will return an empty
    #     string.  Else, it will return a Bootstrap 'danger' alert containing
    #     info about the errors.
    #
    # NOTE: the contract must use dry-validation for validation, not
    # ActiveModel. For ActiveModel errors use ValidationErrorsAlert::ActiveModel
    #
    # Reform will drop support for ActiveModel eventually, so we should start
    # thinking about converting all AM forms to use dry-v.
    class ValidationErrorsAlert < Abroaders::Cell::Base
      property :errors

      def show
        return '' if error_messages.empty?
        cell(ErrorAlert, nil, content: render)
      end

      private

      # will return a Hash in the format { key: ['err1', 'err2'] }.
      def error_messages
        errors.messages
      end

      # @!method self.call(model, options = {})
      #   @param model [Model] anything with an `errors` method that returns
      #     ActiveModel-style error messages. Could be an ActiveRecord object,
      #     a reform form that's not using dry-v, or anything that includes
      #     ActiveModel::Validations
      #   @option options [String] model_name the name of the model that will
      #     be displayed to the user in the sentence "there were X errors with
      #     (model name). If the option isn't provided then the cell tries to
      #     figure it out by looking at the ActiveModel::Name object returned
      #     by model.model_name.
      class ActiveModel < Abroaders::Cell::Base
        property :errors

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

        # @return [ActiveModel::Name]
        def model_name
          return options.fetch(:model_name) if options.key?(:model_name)
          name_obj = if model.respond_to?(:model_name)
                       model.model_name
                     else # if it's a Reform contract it will respond to `model`:
                       model.model.model_name
                     end
          name_obj.human.downcase
        end
      end
    end
  end
end
