module AdminArea
  module CardAccounts
    class Update < ::CardAccount::Update
      step Nested(AdminArea::CardAccounts::Edit), name: 'nested.edit', override: true
    end
  end
end
