module Card::Admin
  class Contract < ::Card::Contract
    class Update < self
      property :product_id, type: ::Types::Form::Int
    end
  end
end
