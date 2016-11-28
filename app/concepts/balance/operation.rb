require_dependency 'reform/form/dry'

class Balance < ApplicationRecord
  class Create < Trailblazer::Operation
    include Model
    model Balance, :create

    contract do
      feature Reform::Form::Coercion
      feature Reform::Form::Dry

      property :value,       type: ::Types::Form::Int
      property :currency_id, type: ::Types::Form::Int

      validation do
        required(:currency_id).filled
        required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
      end
    end

    def process(params)
      validate(params[:balance], &:save)
    end

    private

    def setup_model!(params)
      model.person = params[:current_account].people.find(params[:person_id])
    end
  end
end
