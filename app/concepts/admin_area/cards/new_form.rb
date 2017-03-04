module AdminArea
  module Cards
    # Like the 'edit' form, except they can also specify the product ID
    class NewForm < Card::Form
      property :product_id, type: ::Types::Form::Int
    end
  end
end
