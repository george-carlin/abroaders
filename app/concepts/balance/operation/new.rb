require 'reform/form/dry'
require 'trailblazer/operation/contract'

class Balance < Balance.superclass
  module Operation
    # params: person_id
    class New < Trailblazer::Operation
      extend Contract::DSL

      contract do
        feature Reform::Form::Coercion
        feature Reform::Form::Dry

        property :value,       type: Types::Form::Int
        property :currency_id, type: Types::Form::Int

        validation do
          required(:currency_id).filled
          required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
        end
      end

      step :setup_person
      step :setup_model
      step Contract::Build()

      private

      def setup_person(opts, account:, params:, **)
        opts['person'] = account.people.find(params.fetch(:person_id))
      end

      def setup_model(opts, person:, **)
        opts['model'] = person.balances.new
      end
    end
  end
end
