module Card::Admin
  class Contract < ::Card::Contract
    property :product_id, type: ::Types::Form::Int
  end
end
