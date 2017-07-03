class CardAccount < CardAccount.superclass
  class Update < Card::Update
    self['edit_op'] = CardAccount::Edit
  end
end
