require 'reform/form/dry'

class Balance < Balance.superclass
  class EditForm < Reform::Form
    feature Reform::Form::Coercion
    feature Reform::Form::Dry

    model :balance

    property :value, type: ::Types::Form::Int

    validation do
      required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
    end
  end
end
