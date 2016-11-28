require_dependency 'reform/form/dry'

class Balance::EditForm < Reform::Form
  feature Reform::Form::Coercion
  feature Reform::Form::Dry

  def self.model_name
    Balance.model_name
  end

  property :value, type: ::Types::Form::Int

  validation do
    required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
  end
end
