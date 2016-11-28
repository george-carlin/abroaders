require_dependency 'reform/form/coercion'
require_dependency 'reform/form/dry'

class Bank::Form < Reform::Form
  feature Reform::Form::Coercion
  feature Reform::Form::Dry

  property :name,           type: Types::Stripped::String
  property :business_phone, type: Types::Stripped::String.optional
  property :personal_phone, type: Types::Stripped::String.optional

  validation do
    required(:name).filled(:str?)
    required(:business_phone).maybe(:str?)
    required(:personal_phone).maybe(:str?)
  end
end
