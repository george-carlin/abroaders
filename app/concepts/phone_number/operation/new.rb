require 'reform/form/dry'

class PhoneNumber < ApplicationRecord
  module Operation
    class New < Trailblazer::Operation
      extend Contract::DSL

      contract do
        feature Reform::Form::Coercion
        feature Reform::Form::Dry

        property :number, type: Types::StrippedString

        validation do
          required(:number).filled { str? && max_size?(15) }
        end
      end

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(options, account:, **)
        options['model'] = PhoneNumber.new(account: account)
      end
    end
  end
end
