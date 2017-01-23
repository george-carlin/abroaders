require 'reform/form/dry'

class PhoneNumber < ApplicationRecord
  module Operations
    class New < Trailblazer::Operation
      extend Contract::DSL

      contract do
        feature Reform::Form::Coercion
        feature Reform::Form::Dry

        property :number, type: Types::Stripped::String

        validation do
          required(:number).filled { str? && max_size?(15) }
        end
      end

      step :setup_model!
      step Contract::Build()

      private

      def setup_model!(options, current_account:, **)
        options['model'] = PhoneNumber.new(account: current_account)
      end
    end
  end
end
