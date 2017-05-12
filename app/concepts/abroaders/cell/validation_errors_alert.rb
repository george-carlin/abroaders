module Abroaders
  module Cell
    # Takes an object that responds to `.errors` (e.g. a Reform form). If
    # there are any errors, renders an error alert with info about the
    # errors. Else, renders nothing.
    #
    # The errors object can use ActiveModel or dry-validation.  Reform will
    # drop support for ActiveModel eventually, so we should start thinking
    # about converting all AM forms to use dry-v.
    #
    # @!method self.call(model, options = {})
    #   @param model [Object] Anything that responds to `.errors` and returns
    #     either an ActiveModel-style or a dry-validation-style error object.
    #     In other words, the model could be an ActiveRecord model, a Reform
    #     contract, the return value of a dry-validation schema, or anything
    #     that includes ActiveModel::Validations
    #
    #   @option options [String] model_name the name of the model that will be
    #     displayed to the user in the sentence "there were X errors with
    #     (model name). If the option isn't provided then the cell tries to
    #     figure it out by looking at the ActiveModel::Name object returned by
    #     model.model_name.
    #
    #     This option is only relevant if the model uses ActiveModel.  If it
    #     uses dry-validation, then no model name will be displayed, so passing
    #     in a model_name will have no effect.
    class ValidationErrorsAlert < Abroaders::Cell::Base
      include ::Cell::Builder

      property :errors
      option :model_name, optional: true

      builds do |model|
        case model.errors
        when Reform::Form::ActiveModel::Errors, ::ActiveModel::Errors
          ValidationErrorsAlert::ActiveModel
        end
      end

      def show
        return '' if no_errors?
        cell(ErrorAlert, nil, content: "#{intro} #{list_of_errors}")
      end

      private

      def intro
        'Error:'
      end

      def list_items
        errors.messages.map do |attr, errs|
          "<li>#{Inflecto.humanize(attr.to_s)} #{errs.to_sentence}</li>"
        end
      end

      # will return a Hash in the format { key: ['err1', 'err2'] }.
      def list_of_errors
        "<ul>#{list_items.join}</ul>"
      end

      def no_errors?
        errors.messages.empty?
      end

      class ActiveModel < self
        property :errors

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

        def list_items
          errors.full_messages.map do |error|
            "<li>#{error}</li>"
          end
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

        def no_errors?
          errors.empty?
        end
      end
    end
  end
end
