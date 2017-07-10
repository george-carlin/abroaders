require 'reform/form/dry'

module PhoneNumber
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract do
      feature Reform::Form::Coercion
      feature Reform::Form::Dry

      property :phone_number, type: Types::StrippedString

      validation do
        required(:phone_number).filled { str? && max_size?(15) }
      end
    end

    step :find_model!
    step Contract::Build()

    private

    def find_model!(opts, current_account:, **)
      opts['model'] = current_account
    end
  end
end
