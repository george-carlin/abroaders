# TODO why isn't this autoloaded?
require "reform/form/coercion"

class Bank::Form < Reform::Form
  feature Reform::Form::Coercion

  property :name,           type: Types::Stripped::String
  property :business_phone, type: Types::Stripped::String.optional
  property :personal_phone, type: Types::Stripped::String.optional

  validation do
    required(:name).filled(:str?)
    required(:business_phone).maybe(:str?)
    required(:personal_phone).maybe(:str?)
  end
end
