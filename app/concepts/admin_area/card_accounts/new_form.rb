module AdminArea
  module CardAccounts
    class NewForm < ::CardAccount::Form
      property :card_product_id, type: ::Types::Form::Int
    end
  end
end
