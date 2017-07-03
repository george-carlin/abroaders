module AdminArea
  module CardAccounts
    class Edit < ::CardAccount::Edit
      self['card_scope'] = Card.accounts
    end
  end
end
