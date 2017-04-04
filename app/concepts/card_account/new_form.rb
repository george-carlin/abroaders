class CardAccount < CardAccount.superclass
  class NewForm < ::CardAccount::Form
    property :person_id, type: ::Types::Form::Int
  end
end
