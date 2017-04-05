module AdminArea
  module CardAccounts
    class NewForm < ::CardAccount::Form
      property :product_id, type: ::Types::Form::Int
    end
  end
end
