class Balance < ApplicationRecord
  class Create < Trailblazer::Operation
    include Model
    model Balance, :create

    contract do
      feature Reform::Form::Dry

      property :value
      property :currency_id

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
