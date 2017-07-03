module AdminArea
  module CardAccounts
    class Update < Card::Update
      self['edit_op'] = AdminArea::CardAccounts::Edit
    end
  end
end
