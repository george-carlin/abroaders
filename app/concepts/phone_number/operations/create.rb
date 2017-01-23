class PhoneNumber < ApplicationRecord
  module Operations
    class Create < Trailblazer::Operation
      step Nested(PhoneNumber::Operations::New)
      step Contract::Validate(key: :phone_number)
      step :normalize_number!
      step Contract::Persist()

      private

      def normalize_number!(options, params:, **)
        number = params[:phone_number][:number]
        model  = options['model']
        model.normalized_number = Normalize.(number)
        options['model'] = model
      end
    end
  end
end
