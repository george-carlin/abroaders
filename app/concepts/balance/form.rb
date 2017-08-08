require 'reform/form/dry'

class Balance < Balance.superclass
  class Form < Reform::Form
    feature Reform::Form::Coercion
    feature Reform::Form::Dry

    property :person_id, type: Types::Form::Int
    property :value, type: Types::Form::Int
    property :currency_id, type: Types::Form::Int

    validation do
      required(:currency_id).filled
      required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
    end
  end
end
