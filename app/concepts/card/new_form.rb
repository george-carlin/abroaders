class Card < ApplicationRecord
  # Like the 'edit' form, except they can also specify the product ID
  class NewForm < ::Card::Form
    property :product_id, type: ::Types::Form::Int
    property :person_id,  type: ::Types::Form::Int
  end
end
